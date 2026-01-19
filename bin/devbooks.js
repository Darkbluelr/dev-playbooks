#!/usr/bin/env node

/**
 * DevBooks CLI
 *
 * AI-agnostic spec-driven development workflow
 *
 * Usage:
 *   dev-playbooks init [path] [options]
 *   dev-playbooks update [path]           # Update CLI and configured tools
 *   dev-playbooks migrate --from <framework> [options]
 *
 * Options:
 *   --tools <tools>    Non-interactive tool selection: all, none, or comma-separated list
 *   --from <framework> Migration source: openspec, speckit
 *   --dry-run          Dry run, don't modify files
 *   --keep-old         Keep old directory after migration
 *   --help             Show help
 *   --version          Show version
 */

import fs from 'fs';
import path from 'path';
import os from 'os';
import { fileURLToPath } from 'url';
import { spawn } from 'child_process';
import { checkbox, confirm, select } from '@inquirer/prompts';
import chalk from 'chalk';
import ora from 'ora';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const CLI_COMMAND = 'dev-playbooks';
const XDG_CONFIG_HOME = process.env.XDG_CONFIG_HOME || path.join(os.homedir(), '.config');

// ============================================================================
// Skills 支持级别定义
// ============================================================================

const SKILLS_SUPPORT = {
  FULL: 'full',      // 完整 Skills 系统（可独立调用、有独立上下文）
  RULES: 'rules',    // Rules 类似系统（自动应用的规则）
  AGENTS: 'agents',  // Agents/自定义指令（项目级指令文件）
  BASIC: 'basic'     // 仅基础指令（无独立 Skills 概念）
};

// ============================================================================
// Skills Install Scope
// ============================================================================

const INSTALL_SCOPE = {
  GLOBAL: 'global',   // Global installation (~/.claude/skills etc.)
  PROJECT: 'project'  // Project-level installation (.claude/skills etc.)
};

// ============================================================================
// AI 工具配置
// ============================================================================

const AI_TOOLS = [
  // === 完整 Skills 支持 ===
  {
    id: 'claude',
    name: 'Claude Code',
    description: 'Anthropic Claude Code CLI',
    skillsSupport: SKILLS_SUPPORT.FULL,
    slashDir: '.claude/commands/devbooks',
    skillsDir: path.join(os.homedir(), '.claude', 'skills'),
    instructionFile: 'CLAUDE.md',
    available: true
  },
  {
    id: 'qoder',
    name: 'Qoder CLI',
    description: 'Qoder AI Coding Assistant',
    skillsSupport: SKILLS_SUPPORT.FULL,
    slashDir: '.qoder/commands/devbooks',
    agentsDir: 'agents',
    globalDir: path.join(os.homedir(), '.qoder'),
    instructionFile: 'AGENTS.md',
    available: true
  },
  {
    id: 'opencode',
    name: 'OpenCode',
    description: 'OpenCode AI CLI (compatible with oh-my-opencode)',
    skillsSupport: SKILLS_SUPPORT.FULL,
    slashDir: '.opencode/command',
    agentsDir: '.opencode/agent',
    skillsDir: path.join(XDG_CONFIG_HOME, 'opencode', 'skill'),
    globalDir: path.join(XDG_CONFIG_HOME, 'opencode'),
    instructionFile: 'AGENTS.md',
    available: true
  },

  // === Rules 类似系统 ===
  {
    id: 'cursor',
    name: 'Cursor',
    description: 'Cursor AI IDE',
    skillsSupport: SKILLS_SUPPORT.RULES,
    slashDir: '.cursor/commands/devbooks',
    rulesDir: '.cursor/rules',
    instructionFile: null,
    available: true
  },
  {
    id: 'windsurf',
    name: 'Windsurf',
    description: 'Codeium Windsurf IDE',
    skillsSupport: SKILLS_SUPPORT.RULES,
    slashDir: '.windsurf/commands/devbooks',
    rulesDir: '.windsurf/rules',
    instructionFile: null,
    available: true
  },
  {
    id: 'gemini',
    name: 'Gemini CLI',
    description: 'Google Gemini CLI',
    skillsSupport: SKILLS_SUPPORT.RULES,
    slashDir: '.gemini/commands/devbooks',
    rulesDir: '.gemini',
    globalDir: path.join(os.homedir(), '.gemini'),
    instructionFile: 'GEMINI.md',
    available: true
  },
  {
    id: 'antigravity',
    name: 'Antigravity',
    description: 'Google Antigravity (VS Code)',
    skillsSupport: SKILLS_SUPPORT.RULES,
    slashDir: '.agent/workflows/devbooks',
    rulesDir: '.agent/rules',
    globalDir: path.join(os.homedir(), '.gemini', 'antigravity'),
    instructionFile: 'GEMINI.md',
    available: true
  },

  // === Agents/自定义指令 ===
  {
    id: 'github-copilot',
    name: 'GitHub Copilot',
    description: 'GitHub Copilot (VS Code / JetBrains)',
    skillsSupport: SKILLS_SUPPORT.AGENTS,
    instructionsDir: '.github/instructions',
    instructionFile: '.github/copilot-instructions.md',
    available: true
  },

  // === Continue（Rules/Prompts 系统）===
  {
    id: 'continue',
    name: 'Continue',
    description: 'Continue (VS Code / JetBrains)',
    skillsSupport: SKILLS_SUPPORT.RULES,
    slashDir: '.continue/prompts/devbooks',
    rulesDir: '.continue/rules',
    instructionFile: null,
    available: true
  },

  // === Codex CLI（完整 Skills 支持）===
  {
    id: 'codex',
    name: 'Codex CLI',
    description: 'OpenAI Codex CLI',
    skillsSupport: SKILLS_SUPPORT.FULL,
    slashDir: null,
    skillsDir: path.join(os.homedir(), '.codex', 'skills'),
    globalSlashDir: path.join(os.homedir(), '.codex', 'prompts'),
    instructionFile: 'AGENTS.md',
    available: true
  },

  // === Every Code / just-every/code (Full Skills Support) ===
  {
    id: 'code',
    name: 'Every Code',
    description: 'Every Code CLI (@just-every/code)',
    skillsSupport: SKILLS_SUPPORT.FULL,
    slashDir: null,
    skillsDir: path.join(os.homedir(), '.code', 'skills'),
    globalSlashDir: null,
    instructionFile: 'AGENTS.md',
    available: true
  }
];

const DEVBOOKS_MARKERS = {
  start: '<!-- DEVBOOKS:START -->',
  end: '<!-- DEVBOOKS:END -->'
};

// ============================================================================
// 辅助函数
// ============================================================================

function expandPath(p) {
  if (p.startsWith('~')) {
    return path.join(os.homedir(), p.slice(1));
  }
  return p;
}

/**
 * Update content between DEVBOOKS:START/END markers in a file
 * Preserves user customizations outside the markers
 */
function updateManagedContent(filePath, newManagedContent) {
  if (!fs.existsSync(filePath)) {
    return false;
  }

  const content = fs.readFileSync(filePath, 'utf-8');
  const startMarker = DEVBOOKS_MARKERS.start;
  const endMarker = DEVBOOKS_MARKERS.end;

  const startIdx = content.indexOf(startMarker);
  const endIdx = content.indexOf(endMarker);

  if (startIdx === -1 || endIdx === -1 || startIdx >= endIdx) {
    // No valid markers found, cannot update
    return false;
  }

  // Extract the managed block from new content
  const newStartIdx = newManagedContent.indexOf(startMarker);
  const newEndIdx = newManagedContent.indexOf(endMarker);

  if (newStartIdx === -1 || newEndIdx === -1) {
    return false;
  }

  const newManagedBlock = newManagedContent.slice(newStartIdx, newEndIdx + endMarker.length);

  // Replace the old managed block
  const before = content.slice(0, startIdx);
  const after = content.slice(endIdx + endMarker.length);
  const updatedContent = before + newManagedBlock + after;

  if (updatedContent !== content) {
    fs.writeFileSync(filePath, updatedContent);
    return true;
  }

  return false;
}

function copyDirSync(src, dest) {
  if (!fs.existsSync(src)) return 0;
  fs.mkdirSync(dest, { recursive: true });
  let count = 0;

  const entries = fs.readdirSync(src, { withFileTypes: true });
  for (const entry of entries) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);

    if (entry.isDirectory()) {
      count += copyDirSync(srcPath, destPath);
    } else if (entry.isSymbolicLink()) {
      // Skip symlinks to avoid broken links
      continue;
    } else {
      fs.copyFileSync(srcPath, destPath);
      count++;
    }
  }
  return count;
}

function pruneRemovedSkills(skillsDestDir, allowedSkillNames) {
  if (!fs.existsSync(skillsDestDir)) return 0;
  let removedCount = 0;
  const entries = fs.readdirSync(skillsDestDir, { withFileTypes: true });

  for (const entry of entries) {
    if (!entry.isDirectory()) continue;
    if (!entry.name.startsWith('devbooks-')) continue;
    if (allowedSkillNames.has(entry.name)) continue;

    fs.rmSync(path.join(skillsDestDir, entry.name), { recursive: true, force: true });
    removedCount++;
  }

  return removedCount;
}

function getSkillsSupportLabel(level) {
  switch (level) {
    case SKILLS_SUPPORT.FULL:
      return chalk.green('★ 完整 Skills');
    case SKILLS_SUPPORT.RULES:
      return chalk.blue('◆ Rules 系统');
    case SKILLS_SUPPORT.AGENTS:
      return chalk.yellow('● 自定义指令');
    case SKILLS_SUPPORT.BASIC:
      return chalk.gray('○ 基础支持');
    default:
      return chalk.gray('○ 未知');
  }
}

function getSkillsSupportDescription(level) {
  switch (level) {
    case SKILLS_SUPPORT.FULL:
      return '支持独立 Skills/Agents，可按需调用';
    case SKILLS_SUPPORT.RULES:
      return '支持 Rules 规则系统，自动应用';
    case SKILLS_SUPPORT.AGENTS:
      return '支持项目级自定义指令';
    case SKILLS_SUPPORT.BASIC:
      return '仅支持全局提示词';
    default:
      return '';
  }
}

function getCliVersion() {
  const packagePath = path.join(__dirname, '..', 'package.json');
  try {
    const raw = fs.readFileSync(packagePath, 'utf-8');
    const pkg = JSON.parse(raw);
    return pkg.version || 'unknown';
  } catch {
    return 'unknown';
  }
}

/**
 * Check if a new version is available on npm
 * @returns {Promise<{hasUpdate: boolean, latestVersion: string|null, currentVersion: string}>}
 */
async function checkNpmUpdate() {
  const currentVersion = getCliVersion();
  try {
    const { execSync } = await import('child_process');
    const latestVersion = execSync(`npm view ${CLI_COMMAND} version`, {
      encoding: 'utf-8',
      timeout: 10000,
      stdio: ['pipe', 'pipe', 'pipe']
    }).trim();

    if (latestVersion && latestVersion !== currentVersion) {
      // Simple semver comparison
      const current = currentVersion.split('.').map(Number);
      const latest = latestVersion.split('.').map(Number);
      const hasUpdate = latest[0] > current[0] ||
        (latest[0] === current[0] && latest[1] > current[1]) ||
        (latest[0] === current[0] && latest[1] === current[1] && latest[2] > current[2]);
      return { hasUpdate, latestVersion, currentVersion };
    }
    return { hasUpdate: false, latestVersion, currentVersion };
  } catch {
    // Network error or timeout, silently ignore
    return { hasUpdate: false, latestVersion: null, currentVersion };
  }
}

/**
 * Perform npm global update
 * @returns {Promise<boolean>} Whether the update succeeded
 */
async function performNpmUpdate() {
  return new Promise((resolve) => {
    const spinner = ora(`Updating ${CLI_COMMAND}...`).start();
    const child = spawn('npm', ['install', '-g', CLI_COMMAND], {
      stdio: ['pipe', 'pipe', 'pipe'],
      shell: true
    });

    let stderr = '';
    child.stderr.on('data', (data) => {
      stderr += data.toString();
    });

    child.on('close', (code) => {
      if (code === 0) {
        spinner.succeed(`${CLI_COMMAND} updated to latest version`);
        resolve(true);
      } else {
        spinner.fail(`Update failed: ${stderr || 'Unknown error'}`);
        resolve(false);
      }
    });

    child.on('error', (err) => {
      spinner.fail(`Update failed: ${err.message}`);
      resolve(false);
    });
  });
}

/**
 * Display version changelog summary
 * @param {string} fromVersion - Current version
 * @param {string} toVersion - Target version
 */
async function displayVersionChangelog(fromVersion, toVersion) {
  try {
    // Try to fetch CHANGELOG from GitHub
    const { execSync } = await import('child_process');
    const changelogUrl = `https://raw.githubusercontent.com/Darkbluelr/dev-playbooks/master/CHANGELOG.md`;

    // Use curl to fetch CHANGELOG (if available)
    let changelog = '';
    try {
      changelog = execSync(`curl -s -m 5 "${changelogUrl}"`, {
        encoding: 'utf-8',
        stdio: ['pipe', 'pipe', 'pipe']
      });
    } catch {
      // If fetch fails, show simplified info
      console.log(chalk.cyan('📋 Version Changelog'));
      console.log(chalk.gray('─'.repeat(60)));
      console.log(chalk.yellow('⚠ Unable to fetch detailed changelog, please visit:'));
      console.log(chalk.blue(`   https://github.com/Darkbluelr/dev-playbooks/releases/tag/v${toVersion}`));
      return;
    }

    // Parse CHANGELOG, extract changes for relevant versions
    const changes = parseChangelog(changelog, fromVersion, toVersion);

    if (changes.length === 0) {
      console.log(chalk.cyan('📋 Version Changelog'));
      console.log(chalk.gray('─'.repeat(60)));
      console.log(chalk.yellow('⚠ No detailed changelog found, please visit:'));
      console.log(chalk.blue(`   https://github.com/Darkbluelr/dev-playbooks/releases/tag/v${toVersion}`));
      return;
    }

    // Display changelog summary
    console.log(chalk.cyan('📋 Version Changelog'));
    console.log(chalk.gray('─'.repeat(60)));

    for (const change of changes) {
      console.log();
      console.log(chalk.bold.green(`## ${change.version}`));
      if (change.date) {
        console.log(chalk.gray(`   Release date: ${change.date}`));
      }
      console.log();

      // Display main changes (limit to first 10 lines)
      const highlights = change.content.split('\n')
        .filter(line => line.trim().length > 0)
        .slice(0, 10);

      for (const line of highlights) {
        if (line.startsWith('###')) {
          console.log(chalk.bold.yellow(line));
        } else if (line.startsWith('####')) {
          console.log(chalk.bold(line));
        } else if (line.startsWith('- ✅') || line.startsWith('- ✓')) {
          console.log(chalk.green(line));
        } else if (line.startsWith('- ⚠️') || line.startsWith('- ❌')) {
          console.log(chalk.yellow(line));
        } else if (line.startsWith('- ')) {
          console.log(chalk.white(line));
        } else {
          console.log(chalk.gray(line));
        }
      }

      if (change.content.split('\n').length > 10) {
        console.log(chalk.gray('   ... (see full changelog for more)'));
      }
    }

    console.log();
    console.log(chalk.gray('─'.repeat(60)));
    console.log(chalk.blue('📖 Full changelog: ') + chalk.underline(`https://github.com/Darkbluelr/dev-playbooks/blob/master/CHANGELOG.md`));

  } catch (error) {
    // Silent failure, don't affect update process
    console.log(chalk.gray('Note: Unable to display changelog summary'));
  }
}

/**
 * Parse CHANGELOG content, extract changes for specified version range
 * @param {string} changelog - CHANGELOG content
 * @param {string} fromVersion - Starting version
 * @param {string} toVersion - Target version
 * @returns {Array} - List of changes
 */
function parseChangelog(changelog, fromVersion, toVersion) {
  const changes = [];
  const lines = changelog.split('\n');

  let currentVersion = null;
  let currentDate = null;
  let currentContent = [];
  let inVersionBlock = false;
  let shouldCapture = false;

  // Parse version numbers (remove 'v' prefix)
  const from = fromVersion.replace(/^v/, '');
  const to = toVersion.replace(/^v/, '');

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    // Match version header: ## [2.0.0] - 2026-01-19
    const versionMatch = line.match(/^##\s+\[?(\d+\.\d+\.\d+)\]?\s*(?:-\s*(\d{4}-\d{2}-\d{2}))?/);

    if (versionMatch) {
      // Save previous version's content
      if (inVersionBlock && shouldCapture && currentVersion) {
        changes.push({
          version: currentVersion,
          date: currentDate,
          content: currentContent.join('\n').trim()
        });
      }

      // Start new version
      currentVersion = versionMatch[1];
      currentDate = versionMatch[2] || null;
      currentContent = [];
      inVersionBlock = true;

      // Determine if this version should be captured
      // Capture all versions between fromVersion and toVersion
      const versionNum = currentVersion.split('.').map(Number);
      const fromNum = from.split('.').map(Number);
      const toNum = to.split('.').map(Number);

      const isAfterFrom = compareVersions(versionNum, fromNum) > 0;
      const isBeforeOrEqualTo = compareVersions(versionNum, toNum) <= 0;

      shouldCapture = isAfterFrom && isBeforeOrEqualTo;

      continue;
    }

    // If we encounter next version header or separator, end current version
    if (line.startsWith('---') && inVersionBlock) {
      if (shouldCapture && currentVersion) {
        changes.push({
          version: currentVersion,
          date: currentDate,
          content: currentContent.join('\n').trim()
        });
      }
      inVersionBlock = false;
      shouldCapture = false;
      continue;
    }

    // Collect content
    if (inVersionBlock && shouldCapture) {
      currentContent.push(line);
    }
  }

  // Save last version
  if (inVersionBlock && shouldCapture && currentVersion) {
    changes.push({
      version: currentVersion,
      date: currentDate,
      content: currentContent.join('\n').trim()
    });
  }

  return changes;
}

/**
 * Compare two version numbers
 * @param {number[]} v1 - Version 1 [major, minor, patch]
 * @param {number[]} v2 - Version 2 [major, minor, patch]
 * @returns {number} - 1 if v1 > v2, -1 if v1 < v2, 0 if equal
 */
function compareVersions(v1, v2) {
  for (let i = 0; i < 3; i++) {
    if (v1[i] > v2[i]) return 1;
    if (v1[i] < v2[i]) return -1;
  }
  return 0;
}

// ============================================================================
// Auto-update .gitignore and .npmignore
// ============================================================================

const IGNORE_MARKERS = {
  start: '# DevBooks managed - DO NOT EDIT',
  end: '# End DevBooks managed'
};

/**
 * Get entries to add to .gitignore
 * @param {string[]} toolIds - Selected AI tool IDs
 * @returns {string[]} - Entries to ignore
 */
function getGitIgnoreEntries(toolIds) {
  const entries = [
    '# DevBooks local config (contains user preferences, should not be committed)',
    '.devbooks/'
  ];

  // Add corresponding AI tool directories based on selected tools
  for (const toolId of toolIds) {
    const tool = AI_TOOLS.find(t => t.id === toolId);
    if (!tool) continue;

    // Add slash command directory
    if (tool.slashDir) {
      const topDir = tool.slashDir.split('/')[0];
      if (!entries.includes(topDir + '/')) {
        entries.push(`${topDir}/`);
      }
    }

    // Add rules directory
    if (tool.rulesDir) {
      const topDir = tool.rulesDir.split('/')[0];
      if (!entries.includes(topDir + '/')) {
        entries.push(`${topDir}/`);
      }
    }

    // Add agents directory (e.g., .github/instructions)
    if (tool.instructionsDir) {
      const topDir = tool.instructionsDir.split('/')[0];
      if (topDir !== '.github') { // .github directory usually needs to be kept
        if (!entries.includes(topDir + '/')) {
          entries.push(`${topDir}/`);
        }
      }
    }
  }

  return entries;
}

/**
 * Get entries to add to .npmignore
 * @returns {string[]} - Entries to ignore
 */
function getNpmIgnoreEntries() {
  return [
    '# DevBooks development docs (not needed at runtime)',
    'dev-playbooks/',
    '.devbooks/',
    '',
    '# AI tool config directories',
    '.claude/',
    '.cursor/',
    '.windsurf/',
    '.gemini/',
    '.agent/',
    '.opencode/',
    '.continue/',
    '.qoder/',
    '.code/',
    '.codex/',
    '.github/instructions/',
    '.github/copilot-instructions.md',
    '',
    '# DevBooks instruction files',
    'CLAUDE.md',
    'AGENTS.md',
    'GEMINI.md'
  ];
}

/**
 * Update ignore file, preserving user-defined content
 * @param {string} filePath - ignore file path
 * @param {string[]} entries - Entries to add
 * @returns {object} - { updated: boolean, action: 'created' | 'updated' | 'unchanged' }
 */
function updateIgnoreFile(filePath, entries) {
  const managedBlock = [
    IGNORE_MARKERS.start,
    ...entries,
    IGNORE_MARKERS.end
  ].join('\n');

  if (!fs.existsSync(filePath)) {
    // File doesn't exist, create new file
    fs.writeFileSync(filePath, managedBlock + '\n');
    return { updated: true, action: 'created' };
  }

  const content = fs.readFileSync(filePath, 'utf-8');
  const startIdx = content.indexOf(IGNORE_MARKERS.start);
  const endIdx = content.indexOf(IGNORE_MARKERS.end);

  if (startIdx !== -1 && endIdx !== -1 && startIdx < endIdx) {
    // Managed block exists, update it
    const before = content.slice(0, startIdx);
    const after = content.slice(endIdx + IGNORE_MARKERS.end.length);
    const newContent = before + managedBlock + after;

    if (newContent !== content) {
      fs.writeFileSync(filePath, newContent);
      return { updated: true, action: 'updated' };
    }
    return { updated: false, action: 'unchanged' };
  }

  // No managed block, append to end of file
  const newContent = content.trimEnd() + '\n\n' + managedBlock + '\n';
  fs.writeFileSync(filePath, newContent);
  return { updated: true, action: 'updated' };
}

/**
 * Setup project's ignore files
 * @param {string[]} toolIds - Selected AI tool IDs
 * @param {string} projectDir - Project directory
 * @returns {object[]} - Results array
 */
function setupIgnoreFiles(toolIds, projectDir) {
  const results = [];

  // Update .gitignore
  const gitIgnorePath = path.join(projectDir, '.gitignore');
  const gitIgnoreEntries = getGitIgnoreEntries(toolIds);
  const gitResult = updateIgnoreFile(gitIgnorePath, gitIgnoreEntries);
  if (gitResult.updated) {
    results.push({ file: '.gitignore', action: gitResult.action });
  }

  // Update .npmignore
  const npmIgnorePath = path.join(projectDir, '.npmignore');
  const npmIgnoreEntries = getNpmIgnoreEntries();
  const npmResult = updateIgnoreFile(npmIgnorePath, npmIgnoreEntries);
  if (npmResult.updated) {
    results.push({ file: '.npmignore', action: npmResult.action });
  }

  return results;
}

function showVersion() {
  console.log(`${CLI_COMMAND} v${getCliVersion()}`);
}

// ============================================================================
// Skills 支持说明
// ============================================================================

function printSkillsSupportInfo() {
  console.log();
  console.log(chalk.bold('📚 Skills 支持级别说明'));
  console.log(chalk.gray('─'.repeat(50)));
  console.log();

  console.log(chalk.green('★ 完整 Skills') + chalk.gray(' - Claude Code, Codex CLI, OpenCode, Qoder, Every Code'));
  console.log(chalk.gray('   └ 独立的 Skills/Agents 系统，可按需调用，有独立上下文'));
  console.log();

  console.log(chalk.blue('◆ Rules 系统') + chalk.gray(' - Cursor, Windsurf, Gemini, Antigravity, Continue'));
  console.log(chalk.gray('   └ 规则自动应用于匹配的文件/场景，功能接近 Skills'));
  console.log();

  console.log(chalk.yellow('● 自定义指令') + chalk.gray(' - GitHub Copilot'));
  console.log(chalk.gray('   └ 项目级指令文件，AI 会参考但无法主动调用'));
  console.log();
  console.log(chalk.gray('─'.repeat(50)));
  console.log();
}

// ============================================================================
// 交互式选择（inquirer）
// ============================================================================

async function promptToolSelection(projectDir) {
  printSkillsSupportInfo();

  // 读取已保存的配置
  const config = loadConfig(projectDir);
  const savedTools = config.aiTools || [];
  const hasSavedConfig = savedTools.length > 0;

  const choices = AI_TOOLS.filter(t => t.available).map(tool => {
    const isSelected = hasSavedConfig
      ? savedTools.includes(tool.id)
      : tool.id === 'claude'; // 首次运行默认选中 Claude Code

    return {
      name: `${tool.name} ${chalk.gray(`(${tool.description})`)} ${getSkillsSupportLabel(tool.skillsSupport)}`,
      value: tool.id,
      checked: isSelected
    };
  });

  if (hasSavedConfig) {
    console.log(chalk.blue('ℹ') + ` 检测到已保存的配置: ${savedTools.join(', ')}`);
    console.log();
  }

  const selectedTools = await checkbox({
    message: '选择要配置的 AI 工具（空格选择，回车确认）',
    choices,
    pageSize: 12,
    instructions: false
  });

  if (selectedTools.length === 0) {
    const continueWithoutTools = await confirm({
      message: '未选择任何工具，是否继续（仅创建项目结构）？',
      default: false
    });
    if (!continueWithoutTools) {
      console.log(chalk.yellow('已取消初始化。'));
      process.exit(0);
    }
  }

  return selectedTools;
}

async function promptInstallScope(projectDir, selectedTools) {
  // Check if any tools support full Skills
  const fullSupportTools = selectedTools.filter(id => {
    const tool = AI_TOOLS.find(t => t.id === id);
    return tool && tool.skillsSupport === SKILLS_SUPPORT.FULL;
  });

  if (fullSupportTools.length === 0) {
    return INSTALL_SCOPE.PROJECT; // No full Skills support tools, default to project-level
  }

  // Load saved config
  const config = loadConfig(projectDir);
  const savedScope = config.installScope;

  console.log();
  console.log(chalk.bold('📦 Skills Installation Location'));
  console.log(chalk.gray('─'.repeat(50)));
  console.log();

  const scope = await select({
    message: 'Where should Skills be installed?',
    choices: [
      {
        name: `Project-level ${chalk.gray('(.claude/skills etc., only for this project)')}`,
        value: INSTALL_SCOPE.PROJECT,
        description: 'Recommended: Skills stay with the project, no impact on other projects'
      },
      {
        name: `Global ${chalk.gray('(~/.claude/skills etc., shared across all projects)')}`,
        value: INSTALL_SCOPE.GLOBAL,
        description: 'All projects share the same set of Skills'
      }
    ],
    default: savedScope || INSTALL_SCOPE.PROJECT
  });

  return scope;
}


// ============================================================================
// Install Skills (Claude Code, Codex CLI, Qoder)
// ============================================================================

function getSkillsDestDir(tool, scope, projectDir) {
  // Determine destination directory based on install scope
  if (scope === INSTALL_SCOPE.PROJECT) {
    // Project-level installation: use relative path within project directory
    if (tool.id === 'claude') {
      return path.join(projectDir, '.claude', 'skills');
    } else if (tool.id === 'codex') {
      return path.join(projectDir, '.codex', 'skills');
    } else if (tool.id === 'opencode') {
      return path.join(projectDir, '.opencode', 'skill');
    } else if (tool.id === 'code') {
      return path.join(projectDir, '.code', 'skills');
    }
  }
  // Global installation: use tool's defined global directory
  return tool.skillsDir;
}

function installSkills(toolIds, projectDir, scope = INSTALL_SCOPE.GLOBAL, update = false) {
  const results = [];

  for (const toolId of toolIds) {
    const tool = AI_TOOLS.find(t => t.id === toolId);
    if (!tool || tool.skillsSupport !== SKILLS_SUPPORT.FULL) continue;

    // Claude Code / Codex CLI / OpenCode / Every Code share the same Skills format
    if ((toolId === 'claude' || toolId === 'codex' || toolId === 'opencode' || toolId === 'code') && tool.skillsDir) {
      const skillsSrcDir = path.join(__dirname, '..', 'skills');
      const skillsDestDir = getSkillsDestDir(tool, scope, projectDir);

      if (!fs.existsSync(skillsSrcDir)) continue;

      const skillDirs = fs.readdirSync(skillsSrcDir)
        .filter(name => name.startsWith('devbooks-'))
        .filter(name => fs.statSync(path.join(skillsSrcDir, name)).isDirectory());

      if (skillDirs.length === 0) continue;
      const skillNames = new Set(skillDirs);

      fs.mkdirSync(skillsDestDir, { recursive: true });

      // Install shared directory _shared first (if exists)
      const sharedSrcDir = path.join(skillsSrcDir, '_shared');
      if (fs.existsSync(sharedSrcDir)) {
        const sharedDestDir = path.join(skillsDestDir, '_shared');
        if (update || !fs.existsSync(sharedDestDir)) {
          if (fs.existsSync(sharedDestDir)) {
            fs.rmSync(sharedDestDir, { recursive: true, force: true });
          }
          copyDirSync(sharedSrcDir, sharedDestDir);
        }
      }

      let installedCount = 0;
      for (const skillName of skillDirs) {
        const srcPath = path.join(skillsSrcDir, skillName);
        const destPath = path.join(skillsDestDir, skillName);

        if (fs.existsSync(destPath) && !update) continue;
        if (fs.existsSync(destPath)) {
          fs.rmSync(destPath, { recursive: true, force: true });
        }

        copyDirSync(srcPath, destPath);
        installedCount++;
      }

      const removedCount = update ? pruneRemovedSkills(skillsDestDir, skillNames) : 0;

      results.push({
        tool: tool.name,
        type: 'skills',
        count: installedCount,
        total: skillDirs.length,
        removed: removedCount,
        scope: scope,
        path: skillsDestDir
      });
    }

    // Qoder: Create agents directory structure (but don't copy Skills, different format)
    if (toolId === 'qoder') {
      results.push({ tool: 'Qoder', type: 'agents', count: 0, total: 0, note: 'Manual agents/ creation required' });
    }
  }

  return results;
}

// ============================================================================
// OpenCode: project-level command entrypoint (.opencode/command/devbooks.md)
// ============================================================================

function generateOpenCodeDevbooksCommand() {
  return `---
description: DevBooks workflow entrypoint (OpenCode / oh-my-opencode)
---

${DEVBOOKS_MARKERS.start}
# DevBooks (OpenCode / oh-my-opencode)

This project uses DevBooks for spec-driven development.

## Quick start

1. **Recommended entry (Router):** type \`/devbooks-router\` in chat
2. Or use natural language: \`Run devbooks-router skill: <your request>\`

> Note: In oh-my-opencode, installed Skills are also available as Slash Commands, so you can call them directly as \`/<skill-name>\`.

## Common commands (use /<skill-name>)

- \`/devbooks-router\`: workflow entry routing (recommends next step)
- \`/devbooks-impact-analysis\`: impact analysis (cross-module / external contracts)
- \`/devbooks-proposal-author\`: proposal stage (no coding)
- \`/devbooks-design-doc\`: design doc (What/Constraints + AC)
- \`/devbooks-implementation-plan\`: implementation plan (tasks.md)
- \`/devbooks-test-owner\`: acceptance tests + traceability (separate chat)
- \`/devbooks-coder\`: implement per tasks (do not modify tests/)
- \`/devbooks-spec-gardener\`: spec pruning before archive

## Hard constraints

- Before answering or writing code: run config discovery and read the rules doc (\`.devbooks/config.yaml\` → \`dev-playbooks/project.md\` → \`project.md\`)
- New features / breaking changes / architecture changes: create \`dev-playbooks/changes/<id>/\` and produce proposal/design/tasks/verification
- Test Owner and Coder must be in separate conversations; Coder must not modify \`tests/**\`

${DEVBOOKS_MARKERS.end}
`;
}

function installOpenCodeCommands(toolIds, projectDir, update = false) {
  const results = [];

  if (!toolIds.includes('opencode')) return results;

  const destDir = path.join(projectDir, '.opencode', 'command');
  fs.mkdirSync(destDir, { recursive: true });

  const destPath = path.join(destDir, 'devbooks.md');
  const content = generateOpenCodeDevbooksCommand();

  if (!fs.existsSync(destPath)) {
    fs.writeFileSync(destPath, content);
    results.push({ tool: 'OpenCode', type: 'command', path: destPath, action: 'created' });
  } else if (update) {
    const updated = updateManagedContent(destPath, content);
    if (updated) {
      results.push({ tool: 'OpenCode', type: 'command', path: destPath, action: 'updated' });
    }
  }

  return results;
}

// ============================================================================
// Install Claude Code Custom Subagents (solves built-in subagents cannot access Skills)
// ============================================================================

function installClaudeAgents(toolIds, projectDir, update = false) {
  const results = [];

  // Only Claude Code needs custom subagents
  if (!toolIds.includes('claude')) return results;

  const agentsSrcDir = path.join(__dirname, '..', 'templates', 'claude-agents');
  const agentsDestDir = path.join(projectDir, '.claude', 'agents');

  if (!fs.existsSync(agentsSrcDir)) return results;

  const agentFiles = fs.readdirSync(agentsSrcDir)
    .filter(name => name.endsWith('.md'));

  if (agentFiles.length === 0) return results;

  fs.mkdirSync(agentsDestDir, { recursive: true });

  let installedCount = 0;
  for (const agentFile of agentFiles) {
    const srcPath = path.join(agentsSrcDir, agentFile);
    const destPath = path.join(agentsDestDir, agentFile);

    if (fs.existsSync(destPath) && !update) continue;

    fs.copyFileSync(srcPath, destPath);
    installedCount++;
  }

  if (installedCount > 0) {
    results.push({
      tool: 'Claude Code',
      type: 'agents',
      count: installedCount,
      total: agentFiles.length,
      path: agentsDestDir
    });
  }

  return results;
}

// ============================================================================
// Install Rules (Cursor, Windsurf, Gemini, Antigravity, OpenCode, Continue)
// ============================================================================

function installRules(toolIds, projectDir, update = false) {
  const results = [];

  for (const toolId of toolIds) {
    const tool = AI_TOOLS.find(t => t.id === toolId);
    if (!tool || tool.skillsSupport !== SKILLS_SUPPORT.RULES) continue;

    if (tool.rulesDir) {
      const rulesDestDir = path.join(projectDir, tool.rulesDir);
      fs.mkdirSync(rulesDestDir, { recursive: true });

      // Create devbooks.md rule file
      const ruleContent = generateRuleContent(toolId);
      const ruleFileName = toolId === 'gemini' ? 'GEMINI.md' : 'devbooks.md';
      const rulePath = path.join(rulesDestDir, ruleFileName);

      if (!fs.existsSync(rulePath)) {
        fs.writeFileSync(rulePath, ruleContent);
        results.push({ tool: tool.name, type: 'rules', path: rulePath, action: 'created' });
      } else if (update) {
        // Update existing file's DEVBOOKS:START/END content
        const updated = updateManagedContent(rulePath, ruleContent);
        if (updated) {
          results.push({ tool: tool.name, type: 'rules', path: rulePath, action: 'updated' });
        }
      }
    }
  }

  return results;
}

function generateRuleContent(toolId) {
  const frontmatter = {
    cursor: `---
description: DevBooks 工作流规则
globs: ["**/*"]
---`,
    windsurf: `---
trigger: model_decision
description: DevBooks 工作流规则 - 在处理功能开发、架构变更时自动应用
---`,
    gemini: '',
    antigravity: `---
description: DevBooks 工作流规则
---`,
    opencode: '',
    continue: `---
name: DevBooks 工作流规则
description: DevBooks spec-driven development workflow
---`
  };

  return `${frontmatter[toolId] || ''}
${DEVBOOKS_MARKERS.start}
# DevBooks 工作流规则

## 协议发现

在回答任何问题或写任何代码前，按以下顺序查找配置：
1. \`.devbooks/config.yaml\`（如存在）→ 解析并使用其中的映射
2. \`dev-playbooks/project.md\`（如存在）→ DevBooks 协议

## 核心约束

- Test Owner 与 Coder 必须独立对话/独立实例
- Coder 禁止修改 tests/
- 任何新功能/破坏性变更/架构改动：必须先创建 \`dev-playbooks/changes/<id>/\`

## 工作流 Skills

| Skill | 说明 |
|------|------|
| \`devbooks-proposal-author\` | 创建变更提案 |
| \`devbooks-design-doc\` | 创建设计文档 |
| \`devbooks-test-owner / devbooks-coder\` | 执行实现 |
| \`devbooks-archiver\` | 归档变更包 |

${DEVBOOKS_MARKERS.end}
`;
}

// ============================================================================
// 安装自定义指令文件
// ============================================================================

function installInstructionFiles(toolIds, projectDir, update = false) {
  const results = [];

  for (const toolId of toolIds) {
    const tool = AI_TOOLS.find(t => t.id === toolId);
    if (!tool) continue;

    // GitHub Copilot special handling
    if (toolId === 'github-copilot') {
      const instructionsDir = path.join(projectDir, '.github', 'instructions');
      fs.mkdirSync(instructionsDir, { recursive: true });

      const copilotInstructionPath = path.join(projectDir, '.github', 'copilot-instructions.md');
      const copilotContent = generateCopilotInstructions();
      if (!fs.existsSync(copilotInstructionPath)) {
        fs.writeFileSync(copilotInstructionPath, copilotContent);
        results.push({ tool: 'GitHub Copilot', type: 'instructions', path: copilotInstructionPath, action: 'created' });
      } else if (update) {
        const updated = updateManagedContent(copilotInstructionPath, copilotContent);
        if (updated) {
          results.push({ tool: 'GitHub Copilot', type: 'instructions', path: copilotInstructionPath, action: 'updated' });
        }
      }

      // Create devbooks.instructions.md
      const devbooksInstructionPath = path.join(instructionsDir, 'devbooks.instructions.md');
      const devbooksContent = generateCopilotDevbooksInstructions();
      if (!fs.existsSync(devbooksInstructionPath)) {
        fs.writeFileSync(devbooksInstructionPath, devbooksContent);
        results.push({ tool: 'GitHub Copilot', type: 'instructions', path: devbooksInstructionPath, action: 'created' });
      } else if (update) {
        const updated = updateManagedContent(devbooksInstructionPath, devbooksContent);
        if (updated) {
          results.push({ tool: 'GitHub Copilot', type: 'instructions', path: devbooksInstructionPath, action: 'updated' });
        }
      }
    }

    // Create AGENTS.md / CLAUDE.md / GEMINI.md
    if (tool.instructionFile && !tool.instructionFile.includes('/')) {
      const instructionPath = path.join(projectDir, tool.instructionFile);
      const instructionContent = generateAgentsContent(tool.instructionFile);
      if (!fs.existsSync(instructionPath)) {
        fs.writeFileSync(instructionPath, instructionContent);
        results.push({ tool: tool.name, type: 'instruction', path: instructionPath, action: 'created' });
      } else if (update) {
        const updated = updateManagedContent(instructionPath, instructionContent);
        if (updated) {
          results.push({ tool: tool.name, type: 'instruction', path: instructionPath, action: 'updated' });
        }
      }
    }
  }

  return results;
}

function generateCopilotInstructions() {
  return `${DEVBOOKS_MARKERS.start}
# GitHub Copilot 项目指令

## DevBooks 协议

本项目使用 DevBooks 工作流进行开发。

### 协议发现

在回答问题或写代码前，检查：
1. \`.devbooks/config.yaml\` - DevBooks 配置
2. \`dev-playbooks/project.md\` - 项目规范

### 核心约束

- 新功能/架构变更需先创建提案
- Test Owner 与 Coder 角色分离
- 禁止在 coder 角色时修改 tests/

${DEVBOOKS_MARKERS.end}
`;
}

function generateCopilotDevbooksInstructions() {
  return `---
applyTo: "dev-playbooks/**/*"
description: "DevBooks 工作流文件处理规则"
---
${DEVBOOKS_MARKERS.start}
# DevBooks 文件处理规则

当编辑 dev-playbooks/ 目录下的文件时：

1. **proposal.md**: 只写 Why/What/Impact，不写实现细节
2. **design.md**: 写 What/Constraints + AC-xxx，不写函数体代码
3. **tasks.md**: 可跟踪的任务项，绑定验收锚点
4. **verification.md**: 追溯矩阵，记录 Red/Green 证据

${DEVBOOKS_MARKERS.end}
`;
}

function generateAgentsContent(filename) {
  const toolHint = filename === 'CLAUDE.md' ? 'Claude Code'
    : filename === 'GEMINI.md' ? 'Gemini CLI / Antigravity'
    : '兼容 AGENTS.md 的 AI 工具';

  return `${DEVBOOKS_MARKERS.start}
# DevBooks 使用说明

这些说明适用于 ${toolHint}。

## DevBooks 协议发现与约束

- **配置发现**：在回答任何问题或写任何代码前，按以下顺序查找配置：
  1. \`.devbooks/config.yaml\`（如存在）→ 解析并使用其中的映射
  2. \`dev-playbooks/project.md\`（如存在）→ DevBooks 协议
- 找到配置后，先阅读 \`agents_doc\`（规则文档），再执行任何操作。
- Test Owner 与 Coder 必须独立对话/独立实例；Coder 禁止修改 tests/。
- 任何新功能/破坏性变更/架构改动：必须先创建 \`dev-playbooks/changes/<id>/\`。

## 工作流 Skills

| Skill | 说明 |
|------|------|
| \`devbooks-proposal-author\` | 创建变更提案 |
| \`devbooks-design-doc\` | 创建设计文档 |
| \`devbooks-test-owner / devbooks-coder\` | 执行实现（test-owner/coder/reviewer） |
| \`devbooks-archiver\` | 归档变更包 |

${DEVBOOKS_MARKERS.end}
`;
}

// ============================================================================
// 创建项目结构
// ============================================================================

function createProjectStructure(projectDir) {
  const templateDir = path.join(__dirname, '..', 'templates');

  const dirs = [
    'dev-playbooks/specs/_meta/anti-patterns',
    'dev-playbooks/specs/architecture',
    'dev-playbooks/changes',
    'dev-playbooks/scripts',
    'dev-playbooks/docs',
    '.devbooks'
  ];

  for (const dir of dirs) {
    fs.mkdirSync(path.join(projectDir, dir), { recursive: true });
  }

  const templateFiles = [
    { src: 'dev-playbooks/README.md', dest: 'dev-playbooks/README.md' },
    { src: 'dev-playbooks/constitution.md', dest: 'dev-playbooks/constitution.md' },
    { src: 'dev-playbooks/project.md', dest: 'dev-playbooks/project.md' },
    { src: 'dev-playbooks/specs/_meta/project-profile.md', dest: 'dev-playbooks/specs/_meta/project-profile.md' },
    { src: 'dev-playbooks/specs/_meta/glossary.md', dest: 'dev-playbooks/specs/_meta/glossary.md' },
    { src: 'dev-playbooks/specs/architecture/fitness-rules.md', dest: 'dev-playbooks/specs/architecture/fitness-rules.md' },
    { src: '.devbooks/config.yaml', dest: '.devbooks/config.yaml' }
  ];

  // 动态添加 docs 目录下的所有文件
  const docsDir = path.join(templateDir, 'dev-playbooks', 'docs');
  if (fs.existsSync(docsDir)) {
    const docFiles = fs.readdirSync(docsDir).filter(f => f.endsWith('.md'));
    for (const docFile of docFiles) {
      templateFiles.push({
        src: `dev-playbooks/docs/${docFile}`,
        dest: `dev-playbooks/docs/${docFile}`
      });
    }
  }

  let copiedCount = 0;
  for (const { src, dest } of templateFiles) {
    const srcPath = path.join(templateDir, src);
    const destPath = path.join(projectDir, dest);

    if (fs.existsSync(srcPath) && !fs.existsSync(destPath)) {
      fs.mkdirSync(path.dirname(destPath), { recursive: true });
      fs.copyFileSync(srcPath, destPath);
      copiedCount++;
    }
  }

  return copiedCount;
}

// ============================================================================
// Save Configuration
// ============================================================================

function saveConfig(toolIds, projectDir, installScope = INSTALL_SCOPE.PROJECT) {
  const configPath = path.join(projectDir, '.devbooks', 'config.yaml');

  // Read existing config or create new
  let configContent = '';
  if (fs.existsSync(configPath)) {
    configContent = fs.readFileSync(configPath, 'utf-8');
  }

  // Update ai_tools section
  const toolsYaml = `ai_tools:\n${toolIds.map(id => `  - ${id}`).join('\n')}`;

  if (configContent.includes('ai_tools:')) {
    // Replace existing ai_tools section
    configContent = configContent.replace(/ai_tools:[\s\S]*?(?=\n\w|\n$|$)/, toolsYaml + '\n');
  } else {
    // Append ai_tools section
    configContent = configContent.trimEnd() + '\n\n' + toolsYaml + '\n';
  }

  // Update install_scope section
  const scopeYaml = `install_scope: ${installScope}`;

  if (configContent.includes('install_scope:')) {
    // Replace existing install_scope section
    configContent = configContent.replace(/install_scope:.*/, scopeYaml);
  } else {
    // Append install_scope section
    configContent = configContent.trimEnd() + '\n\n' + scopeYaml + '\n';
  }

  fs.writeFileSync(configPath, configContent);
}

function loadConfig(projectDir) {
  const configPath = path.join(projectDir, '.devbooks', 'config.yaml');

  if (!fs.existsSync(configPath)) {
    return { aiTools: [], installScope: null };
  }

  const content = fs.readFileSync(configPath, 'utf-8');

  // Parse ai_tools
  // Fix: Use more robust regex that matches until next top-level key (non-indented line) or EOF
  const toolsMatch = content.match(/ai_tools:\s*\n((?:[ \t]+-[ \t]+.+\n?)*)/);
  const tools = toolsMatch
    ? toolsMatch[1]
        .split('\n')
        .map(line => line.trim())
        .filter(line => line.startsWith('-'))
        .map(line => line.replace(/^-\s*/, '').trim())
        .filter(line => line.length > 0)
    : [];

  // Parse install_scope
  const scopeMatch = content.match(/install_scope:\s*(\w+)/);
  const installScope = scopeMatch ? scopeMatch[1] : null;

  return { aiTools: tools, installScope };
}

// ============================================================================
// Init Command
// ============================================================================

async function initCommand(projectDir, options) {
  console.log();
  console.log(chalk.cyan('╔══════════════════════════════════════╗'));
  console.log(chalk.cyan('║') + chalk.bold('       DevBooks Initialization        ') + chalk.cyan('║'));
  console.log(chalk.cyan('╚══════════════════════════════════════╝'));
  console.log();

  // Determine selected tools
  let selectedTools;
  let installScope = INSTALL_SCOPE.PROJECT; // Default to project-level installation

  if (options.tools) {
    if (options.tools === 'all') {
      selectedTools = AI_TOOLS.filter(t => t.available).map(t => t.id);
    } else if (options.tools === 'none') {
      selectedTools = [];
    } else {
      selectedTools = options.tools.split(',').map(t => t.trim()).filter(t =>
        AI_TOOLS.some(tool => tool.id === t)
      );
    }
    console.log(chalk.blue('ℹ') + ` Non-interactive mode: ${selectedTools.length > 0 ? selectedTools.join(', ') : 'none'}`);

    // In non-interactive mode, check --scope option
    if (options.scope) {
      installScope = options.scope === 'global' ? INSTALL_SCOPE.GLOBAL : INSTALL_SCOPE.PROJECT;
    }
  } else {
    selectedTools = await promptToolSelection(projectDir);

    // Interactive scope selection
    installScope = await promptInstallScope(projectDir, selectedTools);
  }

  // Create project structure
  const spinner = ora('Creating project structure...').start();
  const templateCount = createProjectStructure(projectDir);
  spinner.succeed(`Created ${templateCount} template files`);

  // Save configuration (including install scope)
  saveConfig(selectedTools, projectDir, installScope);

  if (selectedTools.length === 0) {
    console.log();
    console.log(chalk.green('✓') + ' DevBooks project structure created!');
    console.log(chalk.gray(`  Run \`${CLI_COMMAND} init\` and select AI tools to configure integration.`));
    return;
  }

  // Install Skills (only for full support tools)
  const fullSupportTools = selectedTools.filter(id => {
    const tool = AI_TOOLS.find(t => t.id === id);
    return tool && tool.skillsSupport === SKILLS_SUPPORT.FULL;
  });

  if (fullSupportTools.length > 0) {
    const skillsSpinner = ora('Installing Skills...').start();
    const skillsResults = installSkills(fullSupportTools, projectDir, installScope);
    skillsSpinner.succeed('Skills installed');

    for (const result of skillsResults) {
      if (result.count > 0) {
        const scopeLabel = result.scope === INSTALL_SCOPE.PROJECT ? 'project-level' : 'global';
        console.log(chalk.gray(`  └ ${result.tool}: ${result.count}/${result.total} ${result.type} (${scopeLabel})`));
        if (result.path) {
          console.log(chalk.gray(`    → ${result.path}`));
        }
      } else if (result.note) {
        console.log(chalk.gray(`  └ ${result.tool}: ${result.note}`));
      }
    }

    // Install Claude Code custom subagents (solves built-in subagents cannot access Skills)
    const agentsResults = installClaudeAgents(fullSupportTools, projectDir);
    for (const result of agentsResults) {
      if (result.count > 0) {
        console.log(chalk.gray(`  └ ${result.tool}: ${result.count} custom subagents → ${result.path}`));
      }
    }
  }

  // Install Rules (for Rules-like system tools)
  const rulesTools = selectedTools.filter(id => {
    const tool = AI_TOOLS.find(t => t.id === id);
    return tool && tool.skillsSupport === SKILLS_SUPPORT.RULES;
  });

  if (rulesTools.length > 0) {
    const rulesSpinner = ora('Installing Rules...').start();
    const rulesResults = installRules(rulesTools, projectDir);
    rulesSpinner.succeed(`创建了 ${rulesResults.length} 个规则文件`);

    for (const result of rulesResults) {
      console.log(chalk.gray(`  └ ${result.tool}: ${path.relative(projectDir, result.path)}`));
    }
  }

  // Install instruction files
  const instructionSpinner = ora('Creating instruction files...').start();
  const instructionResults = installInstructionFiles(selectedTools, projectDir);
  instructionSpinner.succeed(`Created ${instructionResults.length} instruction files`);

  for (const result of instructionResults) {
    console.log(chalk.gray(`  └ ${result.tool}: ${path.relative(projectDir, result.path)}`));
  }

  // OpenCode: project-level command entrypoint (.opencode/command/devbooks.md)
  const openCodeCmdResults = installOpenCodeCommands(selectedTools, projectDir);
  for (const result of openCodeCmdResults) {
    console.log(chalk.gray(`  └ ${result.tool}: ${path.relative(projectDir, result.path)}`));
  }

  // Setup ignore files
  const ignoreSpinner = ora('Configuring ignore files...').start();
  const ignoreResults = setupIgnoreFiles(selectedTools, projectDir);
  if (ignoreResults.length > 0) {
    ignoreSpinner.succeed('Ignore files configured');
    for (const result of ignoreResults) {
      console.log(chalk.gray(`  └ ${result.file}: ${result.action}`));
    }
  } else {
    ignoreSpinner.succeed('Ignore files already up to date');
  }

  // Done
  console.log();
  console.log(chalk.green('══════════════════════════════════════'));
  console.log(chalk.green('✓') + chalk.bold(' DevBooks 初始化完成！'));
  console.log(chalk.green('══════════════════════════════════════'));
  console.log();

  // 显示已配置的工具
  console.log(chalk.white('已配置的 AI 工具：'));
  for (const toolId of selectedTools) {
    const tool = AI_TOOLS.find(t => t.id === toolId);
    if (tool) {
      console.log(`  ${chalk.cyan('▸')} ${tool.name} ${getSkillsSupportLabel(tool.skillsSupport)}`);
    }
  }
  console.log();

  // 下一步提示
  console.log(chalk.bold('下一步：'));
  console.log(`  1. 编辑 ${chalk.cyan('dev-playbooks/project.md')} 添加项目信息`);
  console.log(`  2. 使用 ${chalk.cyan('devbooks-proposal-author')} Skill 创建第一个变更提案`);
  console.log();
}

// ============================================================================
// Update Command
// ============================================================================

async function updateCommand(projectDir) {
  console.log();
  console.log(chalk.bold('DevBooks Update'));
  console.log();

  // 1. Check if CLI has a new version
  const spinner = ora('Checking for CLI updates...').start();
  const { hasUpdate, latestVersion, currentVersion } = await checkNpmUpdate();

  if (hasUpdate) {
    spinner.info(`New version available: ${currentVersion} → ${latestVersion}`);

    // Display version changelog summary
    console.log();
    await displayVersionChangelog(currentVersion, latestVersion);
    console.log();

    const shouldUpdate = await confirm({
      message: `Update ${CLI_COMMAND} to ${latestVersion}?`,
      default: true
    });

    if (shouldUpdate) {
      const success = await performNpmUpdate();
      if (success) {
        console.log(chalk.blue('ℹ') + ` Please run \`${CLI_COMMAND} update\` again to update project files.`);
        return;
      }
      // Update failed, continue with local file updates
    }
  } else {
    spinner.succeed(`CLI is up to date (v${currentVersion})`);
  }

  console.log();

  // 2. Check if initialized (update project files)
  const configPath = path.join(projectDir, '.devbooks', 'config.yaml');
  if (!fs.existsSync(configPath)) {
    console.log(chalk.red('✗') + ` DevBooks config not found. Please run \`${CLI_COMMAND} init\` first.`);
    process.exit(1);
  }

  // Load config
  const config = loadConfig(projectDir);
  const configuredTools = config.aiTools;
  const installScope = config.installScope || INSTALL_SCOPE.PROJECT;

  if (configuredTools.length === 0) {
    console.log(chalk.yellow('⚠') + ` No AI tools configured. Run \`${CLI_COMMAND} init\` to configure.`);
    return;
  }

  const toolNames = configuredTools.map(id => {
    const tool = AI_TOOLS.find(t => t.id === id);
    return tool ? tool.name : id;
  });
  const scopeLabel = installScope === INSTALL_SCOPE.PROJECT ? 'project-level' : 'global';
  console.log(chalk.blue('ℹ') + ` Detected configured tools: ${toolNames.join(', ')} (${scopeLabel} installation)`);

  // Update Skills (using saved install scope from config)
  const skillsResults = installSkills(configuredTools, projectDir, installScope, true);
  for (const result of skillsResults) {
    if (result.count > 0) {
      console.log(chalk.green('✓') + ` ${result.tool} ${result.type}: updated ${result.count}/${result.total}`);
      if (result.path) {
        console.log(chalk.gray(`    → ${result.path}`));
      }
    }
    if (result.removed && result.removed > 0) {
      console.log(chalk.green('✓') + ` ${result.tool} ${result.type}: removed ${result.removed} obsolete skills`);
    }
  }

  // Update Claude Code custom subagents (project directory)
  const agentsResults = installClaudeAgents(configuredTools, projectDir, true);
  for (const result of agentsResults) {
    if (result.count > 0) {
      console.log(chalk.green('✓') + ` ${result.tool}: updated ${result.count} custom subagents`);
    }
  }

  // Update Rules (project directory)
  const rulesTools = configuredTools.filter(id => {
    const tool = AI_TOOLS.find(t => t.id === id);
    return tool && tool.skillsSupport === SKILLS_SUPPORT.RULES;
  });

  if (rulesTools.length > 0) {
    const rulesResults = installRules(rulesTools, projectDir, true);
    for (const result of rulesResults) {
      if (result.action === 'updated') {
        console.log(chalk.green('✓') + ` ${result.tool}: updated rule file`);
      }
    }
  }

  // Update instruction files (project directory)
  const instructionResults = installInstructionFiles(configuredTools, projectDir, true);
  for (const result of instructionResults) {
    if (result.action === 'updated') {
      console.log(chalk.green('✓') + ` ${result.tool}: updated instruction file ${path.relative(projectDir, result.path)}`);
    }
  }

  // OpenCode: update project-level command entrypoint (.opencode/command/devbooks.md)
  const openCodeCmdResults = installOpenCodeCommands(configuredTools, projectDir, true);
  for (const result of openCodeCmdResults) {
    if (result.action === 'updated') {
      console.log(chalk.green('✓') + ` ${result.tool}: updated command entrypoint ${path.relative(projectDir, result.path)}`);
    }
  }

  console.log();
  console.log(chalk.green('✓') + ' Update complete!');
}

// ============================================================================
// Migrate 命令
// ============================================================================

async function migrateCommand(projectDir, options) {
  console.log();
  console.log(chalk.bold('DevBooks 迁移工具'));
  console.log();

  const { from, dryRun, keepOld, force } = options;

  if (!from) {
    console.log(chalk.red('✗') + ' 请指定迁移来源框架：--from openspec 或 --from speckit');
    console.log();
    console.log(chalk.cyan('示例:'));
    console.log(`  ${CLI_COMMAND} migrate --from openspec`);
    console.log(`  ${CLI_COMMAND} migrate --from speckit`);
    console.log(`  ${CLI_COMMAND} migrate --from openspec --dry-run`);
    process.exit(1);
  }

  const validFrameworks = ['openspec', 'speckit'];
  if (!validFrameworks.includes(from)) {
    console.log(chalk.red('✗') + ` 不支持的框架: ${from}`);
    console.log(chalk.gray(`  支持的框架: ${validFrameworks.join(', ')}`));
    process.exit(1);
  }

  // 确定脚本路径
  const scriptName = from === 'openspec' ? 'migrate-from-openspec.sh' : 'migrate-from-speckit.sh';
  const scriptPath = path.join(__dirname, '..', 'scripts', scriptName);

  if (!fs.existsSync(scriptPath)) {
    console.log(chalk.red('✗') + ` 迁移脚本不存在: ${scriptPath}`);
    process.exit(1);
  }

  // 构建参数
  const args = ['--project-root', projectDir];
  if (dryRun) args.push('--dry-run');
  if (keepOld) args.push('--keep-old');
  if (force) args.push('--force');

  console.log(chalk.blue('ℹ') + ` 迁移来源: ${from}`);
  console.log(chalk.blue('ℹ') + ` 项目目录: ${projectDir}`);
  if (dryRun) console.log(chalk.yellow('ℹ') + ' 模式: DRY-RUN（模拟运行）');
  console.log();

  // 执行脚本
  return new Promise((resolve, reject) => {
    const child = spawn('bash', [scriptPath, ...args], {
      stdio: 'inherit',
      cwd: projectDir
    });

    child.on('close', (code) => {
      if (code === 0) {
        console.log();
        if (!dryRun) {
          console.log(chalk.green('✓') + ' 迁移完成！');
          console.log();
          console.log(chalk.bold('下一步：'));
          console.log(`  运行 ${chalk.cyan(`${CLI_COMMAND} init`)} 安装 DevBooks Skills`);
        }
        resolve();
      } else {
        reject(new Error(`迁移脚本退出码: ${code}`));
      }
    });

    child.on('error', (err) => {
      reject(new Error(`执行迁移脚本失败: ${err.message}`));
    });
  });
}

// ============================================================================
// Help Information
// ============================================================================

function showHelp() {
  console.log();
  console.log(chalk.bold('DevBooks') + ' - AI-agnostic spec-driven development workflow');
  console.log();
  console.log(chalk.cyan('Usage:'));
  console.log(`  ${CLI_COMMAND} init [path] [options]              Initialize DevBooks`);
  console.log(`  ${CLI_COMMAND} update [path]                      Update CLI and configured tools`);
  console.log(`  ${CLI_COMMAND} migrate --from <framework> [opts]  Migrate from other frameworks`);
  console.log();
  console.log(chalk.cyan('Options:'));
  console.log('  --tools <tools>    Non-interactive AI tool selection');
  console.log('                     Values: all, none, or comma-separated tool IDs');
  console.log('  --scope <scope>    Skills installation location (non-interactive mode)');
  console.log('                     Values: project (default), global');
  console.log('  --from <framework> Migration source framework (openspec, speckit)');
  console.log('  --dry-run          Dry run, no actual file modifications');
  console.log('  --keep-old         Keep original directory after migration');
  console.log('  --force            Force re-execute all steps');
  console.log('  -h, --help         Show this help message');
  console.log('  -v, --version      Show version');
  console.log();
  console.log(chalk.cyan('Supported AI Tools:'));

  // Group tools by Skills support level
  const groupedTools = {
    [SKILLS_SUPPORT.FULL]: [],
    [SKILLS_SUPPORT.RULES]: [],
    [SKILLS_SUPPORT.AGENTS]: [],
    [SKILLS_SUPPORT.BASIC]: []
  };

  for (const tool of AI_TOOLS.filter(t => t.available)) {
    groupedTools[tool.skillsSupport].push(tool);
  }

  console.log();
  console.log(chalk.green('  ★ Full Skills Support:'));
  for (const tool of groupedTools[SKILLS_SUPPORT.FULL]) {
    console.log(`    ${tool.id.padEnd(15)} ${tool.name}`);
  }

  console.log();
  console.log(chalk.blue('  ◆ Rules System Support:'));
  for (const tool of groupedTools[SKILLS_SUPPORT.RULES]) {
    console.log(`    ${tool.id.padEnd(15)} ${tool.name}`);
  }

  console.log();
  console.log(chalk.yellow('  ● Custom Instructions Support:'));
  for (const tool of groupedTools[SKILLS_SUPPORT.AGENTS]) {
    console.log(`    ${tool.id.padEnd(15)} ${tool.name}`);
  }

  console.log();
  console.log();
  console.log(chalk.cyan('Examples:'));
  console.log(`  ${CLI_COMMAND} init                        # Interactive initialization`);
  console.log(`  ${CLI_COMMAND} init my-project             # Initialize in my-project directory`);
  console.log(`  ${CLI_COMMAND} init --tools claude,cursor  # Non-interactive (project-level by default)`);
  console.log(`  ${CLI_COMMAND} init --tools claude --scope global  # Non-interactive (global installation)`);
  console.log(`  ${CLI_COMMAND} update                      # Update CLI and Skills`);
  console.log(`  ${CLI_COMMAND} migrate --from openspec     # Migrate from OpenSpec`);
  console.log(`  ${CLI_COMMAND} migrate --from speckit      # Migrate from spec-kit`);
  console.log(`  ${CLI_COMMAND} migrate --from openspec --dry-run  # Dry run migration`);
}

// ============================================================================
// Main Entry
// ============================================================================

async function main() {
  const args = process.argv.slice(2);

  // Parse arguments
  let command = null;
  let projectPath = null;
  const options = {};

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];

    if (arg === '-h' || arg === '--help') {
      showHelp();
      process.exit(0);
    } else if (arg === '-v' || arg === '--version') {
      showVersion();
      process.exit(0);
    } else if (arg === '--tools') {
      options.tools = args[++i];
    } else if (arg === '--scope') {
      options.scope = args[++i];
    } else if (arg === '--from') {
      options.from = args[++i];
    } else if (arg === '--dry-run') {
      options.dryRun = true;
    } else if (arg === '--keep-old') {
      options.keepOld = true;
    } else if (arg === '--force') {
      options.force = true;
    } else if (!arg.startsWith('-')) {
      if (!command) {
        command = arg;
      } else if (!projectPath) {
        projectPath = arg;
      }
    }
  }

  // 确定项目目录
  const projectDir = projectPath ? path.resolve(projectPath) : process.cwd();

  // 执行命令
  try {
    if (command === 'init' || !command) {
      await initCommand(projectDir, options);
    } else if (command === 'update') {
      await updateCommand(projectDir);
    } else if (command === 'migrate') {
      await migrateCommand(projectDir, options);
    } else {
      console.log(chalk.red(`未知命令: ${command}`));
      showHelp();
      process.exit(1);
    }
  } catch (error) {
    if (error.name === 'ExitPromptError') {
      console.log(chalk.yellow('\n已取消。'));
      process.exit(0);
    }
    throw error;
  }
}

main().catch(error => {
  console.error(chalk.red('✗'), error.message);
  process.exit(1);
});
