#!/usr/bin/env node

/**
 * DevBooks CLI
 *
 * AI-agnostic spec-driven development workflow
 *
 * Usage:
 *   devbooks init [path] [options]
 *   devbooks update [path]
 *
 * Options:
 *   --tools <tools>    Non-interactively select AI tools: all, none, or a comma-separated list
 *   --help             Show help
 */

import fs from 'fs';
import path from 'path';
import os from 'os';
import { fileURLToPath } from 'url';
import { checkbox, confirm } from '@inquirer/prompts';
import chalk from 'chalk';
import ora from 'ora';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// ============================================================================
// Skills support levels
// ============================================================================

const SKILLS_SUPPORT = {
  FULL: 'full',      // Full Skills system (callable Skills/Agents with isolated context)
  RULES: 'rules',    // Rules-like system (auto-applied rules)
  AGENTS: 'agents',  // Project-level instruction files (referenced but not callable)
  BASIC: 'basic'     // Basic support (no standalone Skills concept)
};

// ============================================================================
// AI tool configuration
// ============================================================================

const AI_TOOLS = [
  // === Full Skills support ===
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

  // === Rules-like system ===
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
  {
    id: 'opencode',
    name: 'OpenCode',
    description: 'OpenCode AI CLI',
    skillsSupport: SKILLS_SUPPORT.RULES,
    slashDir: '.opencode/commands/devbooks',
    agentsDir: '.opencode/agent',
    globalDir: path.join(os.homedir(), '.config', 'opencode'),
    instructionFile: 'AGENTS.md',
    available: true
  },

  // === Project instructions ===
  {
    id: 'github-copilot',
    name: 'GitHub Copilot',
    description: 'GitHub Copilot (VS Code / JetBrains)',
    skillsSupport: SKILLS_SUPPORT.AGENTS,
    instructionsDir: '.github/instructions',
    instructionFile: '.github/copilot-instructions.md',
    available: true
  },
  {
    id: 'continue',
    name: 'Continue',
    description: 'Continue (VS Code / JetBrains)',
    skillsSupport: SKILLS_SUPPORT.AGENTS,
    slashDir: '.continue/prompts/devbooks',
    instructionFile: null,
    available: true
  },

  // === Basic support ===
  {
    id: 'codex',
    name: 'Codex CLI',
    description: 'OpenAI Codex CLI',
    skillsSupport: SKILLS_SUPPORT.BASIC,
    slashDir: null,
    globalSlashDir: path.join(os.homedir(), '.codex', 'prompts', 'devbooks'),
    instructionFile: 'AGENTS.md',
    available: true
  }
];

const DEVBOOKS_MARKERS = {
  start: '<!-- DEVBOOKS:START -->',
  end: '<!-- DEVBOOKS:END -->'
};

// ============================================================================
// Helpers
// ============================================================================

function expandPath(p) {
  if (p.startsWith('~')) {
    return path.join(os.homedir(), p.slice(1));
  }
  return p;
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

function getSkillsSupportLabel(level) {
  switch (level) {
    case SKILLS_SUPPORT.FULL:
      return chalk.green('★ Full Skills');
    case SKILLS_SUPPORT.RULES:
      return chalk.blue('◆ Rules System');
    case SKILLS_SUPPORT.AGENTS:
      return chalk.yellow('● Project Instructions');
    case SKILLS_SUPPORT.BASIC:
      return chalk.gray('○ Basic Support');
    default:
      return chalk.gray('○ Unknown');
  }
}

function getSkillsSupportDescription(level) {
  switch (level) {
    case SKILLS_SUPPORT.FULL:
      return 'Callable Skills/Agents with isolated context';
    case SKILLS_SUPPORT.RULES:
      return 'Rules are automatically applied to matching contexts/files';
    case SKILLS_SUPPORT.AGENTS:
      return 'Project-level instruction files are referenced by the tool';
    case SKILLS_SUPPORT.BASIC:
      return 'Global instructions only';
    default:
      return '';
  }
}

// ============================================================================
// Skills support info
// ============================================================================

function printSkillsSupportInfo() {
  console.log();
  console.log(chalk.bold('📚 Skills Support Levels'));
  console.log(chalk.gray('─'.repeat(50)));
  console.log();

  console.log(chalk.green('★ Full Skills') + chalk.gray(' - Claude Code, Qoder'));
  console.log(chalk.gray('   └ Callable Skills/Agents with isolated context'));
  console.log();

  console.log(chalk.blue('◆ Rules System') + chalk.gray(' - Cursor, Windsurf, Gemini, Antigravity, OpenCode'));
  console.log(chalk.gray('   └ Rules automatically apply to matching files/contexts (Skills-like)'));
  console.log();

  console.log(chalk.yellow('● Project Instructions') + chalk.gray(' - GitHub Copilot, Continue'));
  console.log(chalk.gray('   └ Project-level instruction files (referenced, not callable)'));
  console.log();

  console.log(chalk.gray('○ Basic Support') + chalk.gray(' - Codex'));
  console.log(chalk.gray('   └ Global instructions only (simulated via AGENTS.md)'));
  console.log();
  console.log(chalk.gray('─'.repeat(50)));
  console.log();
}

// ============================================================================
// Interactive selection (inquirer)
// ============================================================================

async function promptToolSelection() {
  printSkillsSupportInfo();

  const choices = AI_TOOLS.filter(t => t.available).map(tool => ({
    name: `${tool.name} ${chalk.gray(`(${tool.description})`)} ${getSkillsSupportLabel(tool.skillsSupport)}`,
    value: tool.id,
    checked: tool.id === 'claude' // Default: Claude Code
  }));

  const selectedTools = await checkbox({
    message: 'Select AI tools to configure (space to toggle, enter to confirm)',
    choices,
    pageSize: 12,
    instructions: false
  });

  if (selectedTools.length === 0) {
    const continueWithoutTools = await confirm({
      message: 'No tools selected. Continue (create project structure only)?',
      default: false
    });
    if (!continueWithoutTools) {
      console.log(chalk.yellow('Initialization cancelled.'));
      process.exit(0);
    }
  }

  return selectedTools;
}

// ============================================================================
// Install slash commands
// ============================================================================

function installSlashCommands(toolIds, projectDir) {
  const slashSrcDir = path.join(__dirname, '..', 'slash-commands', 'devbooks');

  if (!fs.existsSync(slashSrcDir)) {
    return { results: [], total: 0 };
  }

  const results = [];

  for (const toolId of toolIds) {
    const tool = AI_TOOLS.find(t => t.id === toolId);
    if (!tool) continue;

    let destDir;
    if (tool.slashDir) {
      destDir = path.join(projectDir, tool.slashDir);
    } else if (tool.globalSlashDir) {
      destDir = expandPath(tool.globalSlashDir);
    } else {
      continue;
    }

    const count = copyDirSync(slashSrcDir, destDir);
    results.push({ tool: tool.name, count, path: destDir });
  }

  return { results, total: results.length };
}

// ============================================================================
// Install Skills (Claude Code + Qoder only)
// ============================================================================

function installSkills(toolIds, update = false) {
  const results = [];

  for (const toolId of toolIds) {
    const tool = AI_TOOLS.find(t => t.id === toolId);
    if (!tool || tool.skillsSupport !== SKILLS_SUPPORT.FULL) continue;

    if (toolId === 'claude' && tool.skillsDir) {
      const skillsSrcDir = path.join(__dirname, '..', 'skills');
      const skillsDestDir = tool.skillsDir;

      if (!fs.existsSync(skillsSrcDir)) continue;

      const skillDirs = fs.readdirSync(skillsSrcDir)
        .filter(name => name.startsWith('devbooks-'))
        .filter(name => fs.statSync(path.join(skillsSrcDir, name)).isDirectory());

      if (skillDirs.length === 0) continue;

      fs.mkdirSync(skillsDestDir, { recursive: true });

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

      results.push({ tool: 'Claude Code', type: 'skills', count: installedCount, total: skillDirs.length });
    }

    // Qoder: create agents directory structure (but do not copy Skills; formats differ)
    if (toolId === 'qoder') {
      results.push({ tool: 'Qoder', type: 'agents', count: 0, total: 0, note: 'Manual setup required: create agents/' });
    }
  }

  return results;
}

// ============================================================================
// Install Rules (Cursor, Windsurf, Gemini, Antigravity, OpenCode)
// ============================================================================

function installRules(toolIds, projectDir) {
  const results = [];

  for (const toolId of toolIds) {
    const tool = AI_TOOLS.find(t => t.id === toolId);
    if (!tool || tool.skillsSupport !== SKILLS_SUPPORT.RULES) continue;

    if (tool.rulesDir) {
      const rulesDestDir = path.join(projectDir, tool.rulesDir);
      fs.mkdirSync(rulesDestDir, { recursive: true });

      // Create rule file
      const ruleContent = generateRuleContent(toolId);
      const ruleFileName = toolId === 'gemini' ? 'GEMINI.md' : 'devbooks.md';
      const rulePath = path.join(rulesDestDir, ruleFileName);

      if (!fs.existsSync(rulePath)) {
        fs.writeFileSync(rulePath, ruleContent);
        results.push({ tool: tool.name, type: 'rules', path: rulePath });
      }
    }
  }

  return results;
}

function generateRuleContent(toolId) {
  const frontmatter = {
    cursor: `---
description: DevBooks workflow rules
globs: ["**/*"]
---`,
    windsurf: `---
trigger: model_decision
description: DevBooks workflow rules - auto-applied during feature and architecture work
---`,
    gemini: '',
    antigravity: `---
description: DevBooks workflow rules
---`,
    opencode: ''
  };

  return `${frontmatter[toolId] || ''}
${DEVBOOKS_MARKERS.start}
# DevBooks Workflow Rules

## Protocol discovery

Before answering questions or writing code, discover configuration in this order:
1. \`.devbooks/config.yaml\` (if present) → parse and use its mappings
2. \`dev-playbooks/project.md\` (if present) → DevBooks protocol

## Core constraints

- Test Owner and Coder must work in separate conversations/instances
- Coder must not modify \`tests/\`
- Any new feature/breaking change/architecture change: create \`dev-playbooks/changes/<id>/\` first

## Workflow commands

| Command | Description |
|------|------|
| \`/devbooks:proposal\` | Create a change proposal |
| \`/devbooks:design\` | Create a design doc |
| \`/devbooks:apply <role>\` | Execute implementation |
| \`/devbooks:archive\` | Archive a change package |

${DEVBOOKS_MARKERS.end}
`;
}

// ============================================================================
// Install instruction files
// ============================================================================

function installInstructionFiles(toolIds, projectDir) {
  const results = [];

  for (const toolId of toolIds) {
    const tool = AI_TOOLS.find(t => t.id === toolId);
    if (!tool) continue;

    // GitHub Copilot special handling
    if (toolId === 'github-copilot') {
      const instructionsDir = path.join(projectDir, '.github', 'instructions');
      fs.mkdirSync(instructionsDir, { recursive: true });

      const copilotInstructionPath = path.join(projectDir, '.github', 'copilot-instructions.md');
      if (!fs.existsSync(copilotInstructionPath)) {
        fs.writeFileSync(copilotInstructionPath, generateCopilotInstructions());
        results.push({ tool: 'GitHub Copilot', type: 'instructions', path: copilotInstructionPath });
      }

      // Create devbooks.instructions.md
      const devbooksInstructionPath = path.join(instructionsDir, 'devbooks.instructions.md');
      if (!fs.existsSync(devbooksInstructionPath)) {
        fs.writeFileSync(devbooksInstructionPath, generateCopilotDevbooksInstructions());
        results.push({ tool: 'GitHub Copilot', type: 'instructions', path: devbooksInstructionPath });
      }
    }

    // Create AGENTS.md / CLAUDE.md / GEMINI.md
    if (tool.instructionFile && !tool.instructionFile.includes('/')) {
      const instructionPath = path.join(projectDir, tool.instructionFile);
      if (!fs.existsSync(instructionPath)) {
        fs.writeFileSync(instructionPath, generateAgentsContent(tool.instructionFile));
        results.push({ tool: tool.name, type: 'instruction', path: instructionPath });
      }
    }
  }

  return results;
}

function generateCopilotInstructions() {
  return `${DEVBOOKS_MARKERS.start}
# GitHub Copilot Project Instructions

## DevBooks protocol

This project uses the DevBooks workflow.

### Protocol discovery

Before answering questions or writing code, check:
1. \`.devbooks/config.yaml\` - DevBooks configuration
2. \`dev-playbooks/project.md\` - Project rules

### Core constraints

- New features/architecture changes require a proposal first
- Test Owner and Coder roles must be separated
- Do not modify \`tests/\` while acting as Coder

${DEVBOOKS_MARKERS.end}
`;
}

function generateCopilotDevbooksInstructions() {
  return `---
applyTo: "dev-playbooks/**/*"
description: "Rules for DevBooks workflow files"
---
${DEVBOOKS_MARKERS.start}
# DevBooks File Handling Rules

When editing files under \`dev-playbooks/\`:

1. **proposal.md**: write Why/What/Impact, not implementation details
2. **design.md**: write What/Constraints + AC-xxx, not function bodies
3. **tasks.md**: trackable tasks tied to verification anchors
4. **verification.md**: traceability matrix; record Red/Green evidence

${DEVBOOKS_MARKERS.end}
`;
}

function generateAgentsContent(filename) {
  const toolHint = filename === 'CLAUDE.md' ? 'Claude Code'
    : filename === 'GEMINI.md' ? 'Gemini CLI / Antigravity'
    : 'AI tools compatible with AGENTS.md';

  return `${DEVBOOKS_MARKERS.start}
# DevBooks Usage Instructions

These instructions apply to ${toolHint}.

## DevBooks protocol discovery and constraints

- **Config discovery**: before answering questions or writing code, discover configuration in this order:
  1. \`.devbooks/config.yaml\` (if present) → parse and use its mappings
  2. \`dev-playbooks/project.md\` (if present) → DevBooks protocol
- After discovery, read \`agents_doc\` (rules doc) before performing any operation.
- Test Owner and Coder must work in separate conversations/instances; Coder must not modify \`tests/\`.
- Any new feature/breaking change/architecture change: create \`dev-playbooks/changes/<id>/\` first.

## Workflow commands

| Command | Description |
|------|------|
| \`/devbooks:proposal\` | Create a change proposal |
| \`/devbooks:design\` | Create a design doc |
| \`/devbooks:apply <role>\` | Execute implementation (test-owner/coder/reviewer) |
| \`/devbooks:archive\` | Archive a change package |

${DEVBOOKS_MARKERS.end}
`;
}

// ============================================================================
// Create project structure
// ============================================================================

function createProjectStructure(projectDir) {
  const templateDir = path.join(__dirname, '..', 'templates');

  const dirs = [
    'dev-playbooks/specs/_meta/anti-patterns',
    'dev-playbooks/specs/architecture',
    'dev-playbooks/changes',
    'dev-playbooks/scripts',
    '.devbooks'
  ];

  for (const dir of dirs) {
    fs.mkdirSync(path.join(projectDir, dir), { recursive: true });
  }

  const templateFiles = [
    { src: 'dev-playbooks/constitution.md', dest: 'dev-playbooks/constitution.md' },
    { src: 'dev-playbooks/project.md', dest: 'dev-playbooks/project.md' },
    { src: 'dev-playbooks/specs/_meta/project-profile.md', dest: 'dev-playbooks/specs/_meta/project-profile.md' },
    { src: 'dev-playbooks/specs/_meta/glossary.md', dest: 'dev-playbooks/specs/_meta/glossary.md' },
    { src: 'dev-playbooks/specs/architecture/fitness-rules.md', dest: 'dev-playbooks/specs/architecture/fitness-rules.md' },
    { src: '.devbooks/config.yaml', dest: '.devbooks/config.yaml' }
  ];

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
// Save config
// ============================================================================

function saveConfig(toolIds, projectDir) {
  const configPath = path.join(projectDir, '.devbooks', 'config.yaml');

  // Read existing config or create a new one
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

  fs.writeFileSync(configPath, configContent);
}

function loadConfig(projectDir) {
  const configPath = path.join(projectDir, '.devbooks', 'config.yaml');

  if (!fs.existsSync(configPath)) {
    return { aiTools: [] };
  }

  const content = fs.readFileSync(configPath, 'utf-8');
  const match = content.match(/ai_tools:\s*([\s\S]*?)(?=\n\w|\n$|$)/);

  if (!match) {
    return { aiTools: [] };
  }

  const tools = match[1]
    .split('\n')
    .map(line => line.trim())
    .filter(line => line.startsWith('-'))
    .map(line => line.replace(/^-\s*/, '').trim());

  return { aiTools: tools };
}

// ============================================================================
// Init command
// ============================================================================

async function initCommand(projectDir, options) {
  console.log();
  console.log(chalk.cyan('╔══════════════════════════════════════╗'));
  console.log(chalk.cyan('║') + chalk.bold('        DevBooks Initialization       ') + chalk.cyan('║'));
  console.log(chalk.cyan('╚══════════════════════════════════════╝'));
  console.log();

  // Determine selected tools
  let selectedTools;

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
  } else {
    selectedTools = await promptToolSelection();
  }

  // Create project structure
  const spinner = ora('Creating project structure...').start();
  const templateCount = createProjectStructure(projectDir);
  spinner.succeed(`Created ${templateCount} template files`);

  // Save config
  saveConfig(selectedTools, projectDir);

  if (selectedTools.length === 0) {
    console.log();
    console.log(chalk.green('✓') + ' DevBooks project structure created!');
    console.log(chalk.gray('  Run `devbooks init` and select AI tools to configure integrations.'));
    return;
  }

  // Install slash commands
  const slashSpinner = ora('Installing slash commands...').start();
  const slashResults = installSlashCommands(selectedTools, projectDir);
  slashSpinner.succeed(`Installed slash commands for ${slashResults.results.length} tools`);

  for (const result of slashResults.results) {
    console.log(chalk.gray(`  └ ${result.tool}: ${result.count} commands`));
  }

  // Install Skills (full support tools only)
  const fullSupportTools = selectedTools.filter(id => {
    const tool = AI_TOOLS.find(t => t.id === id);
    return tool && tool.skillsSupport === SKILLS_SUPPORT.FULL;
  });

  if (fullSupportTools.length > 0) {
    const skillsSpinner = ora('Installing Skills...').start();
    const skillsResults = installSkills(fullSupportTools);
    skillsSpinner.succeed('Skills installed');

    for (const result of skillsResults) {
      if (result.count > 0) {
        console.log(chalk.gray(`  └ ${result.tool}: ${result.count}/${result.total} ${result.type}`));
      } else if (result.note) {
        console.log(chalk.gray(`  └ ${result.tool}: ${result.note}`));
      }
    }
  }

  // Install Rules (rules-like tools)
  const rulesTools = selectedTools.filter(id => {
    const tool = AI_TOOLS.find(t => t.id === id);
    return tool && tool.skillsSupport === SKILLS_SUPPORT.RULES;
  });

  if (rulesTools.length > 0) {
    const rulesSpinner = ora('Installing Rules...').start();
    const rulesResults = installRules(rulesTools, projectDir);
    rulesSpinner.succeed(`Created ${rulesResults.length} rule files`);

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

  // Done
  console.log();
  console.log(chalk.green('══════════════════════════════════════'));
  console.log(chalk.green('✓') + chalk.bold(' DevBooks initialization complete!'));
  console.log(chalk.green('══════════════════════════════════════'));
  console.log();

  // Show configured tools
  console.log(chalk.white('Configured AI tools:'));
  for (const toolId of selectedTools) {
    const tool = AI_TOOLS.find(t => t.id === toolId);
    if (tool) {
      console.log(`  ${chalk.cyan('▸')} ${tool.name} ${getSkillsSupportLabel(tool.skillsSupport)}`);
    }
  }
  console.log();

  // Next steps
  console.log(chalk.bold('Next steps:'));
  console.log(`  1. Edit ${chalk.cyan('dev-playbooks/project.md')} and add project context`);
  console.log(`  2. Use ${chalk.cyan('/devbooks:proposal')} to create your first change proposal`);
  console.log();
  console.log(chalk.yellow('Important:'));
  console.log('  Slash commands load when your IDE starts. Restart your AI tool to activate them.');
}

// ============================================================================
// Update command
// ============================================================================

async function updateCommand(projectDir) {
  console.log();
  console.log(chalk.bold('DevBooks Update'));
  console.log();

  // Check whether initialized
  const configPath = path.join(projectDir, '.devbooks', 'config.yaml');
  if (!fs.existsSync(configPath)) {
    console.log(chalk.red('✗') + ' DevBooks config not found. Run `devbooks init` first.');
    process.exit(1);
  }

  // Load config
  const config = loadConfig(projectDir);
  const configuredTools = config.aiTools;

  if (configuredTools.length === 0) {
    console.log(chalk.yellow('⚠') + ' No AI tools configured. Run `devbooks init` to configure.');
    return;
  }

  const toolNames = configuredTools.map(id => {
    const tool = AI_TOOLS.find(t => t.id === id);
    return tool ? tool.name : id;
  });
  console.log(chalk.blue('ℹ') + ` Detected configured tools: ${toolNames.join(', ')}`);

  // Update slash commands
  const slashResults = installSlashCommands(configuredTools, projectDir);
  for (const result of slashResults.results) {
    console.log(chalk.green('✓') + ` ${result.tool}: updated ${result.count} slash commands`);
  }

  // Update Skills
  const skillsResults = installSkills(configuredTools, true);
  for (const result of skillsResults) {
    if (result.count > 0) {
      console.log(chalk.green('✓') + ` ${result.tool} ${result.type}: updated ${result.count}/${result.total}`);
    }
  }

  // Update Rules
  const rulesTools = configuredTools.filter(id => {
    const tool = AI_TOOLS.find(t => t.id === id);
    return tool && tool.skillsSupport === SKILLS_SUPPORT.RULES;
  });

  if (rulesTools.length > 0) {
    const rulesResults = installRules(rulesTools, projectDir);
    for (const result of rulesResults) {
      console.log(chalk.green('✓') + ` ${result.tool}: updated rule files`);
    }
  }

  console.log();
  console.log(chalk.green('✓') + ' Update complete!');
}

// ============================================================================
// Help
// ============================================================================

function showHelp() {
  console.log();
  console.log(chalk.bold('DevBooks') + ' - AI-agnostic spec-driven development workflow');
  console.log();
  console.log(chalk.cyan('Usage:'));
  console.log('  devbooks init [path] [options]    Initialize DevBooks');
  console.log('  devbooks update [path]            Update configured tools');
  console.log();
  console.log(chalk.cyan('Options:'));
  console.log('  --tools <tools>    Non-interactively select AI tools');
  console.log('                     Values: all, none, or comma-separated tool IDs');
  console.log('  -h, --help         Show this help');
  console.log();
  console.log(chalk.cyan('Supported AI tools:'));

  // Group by support level
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
  console.log(chalk.green('  ★ Full Skills support:'));
  for (const tool of groupedTools[SKILLS_SUPPORT.FULL]) {
    console.log(`    ${tool.id.padEnd(15)} ${tool.name}`);
  }

  console.log();
  console.log(chalk.blue('  ◆ Rules system support:'));
  for (const tool of groupedTools[SKILLS_SUPPORT.RULES]) {
    console.log(`    ${tool.id.padEnd(15)} ${tool.name}`);
  }

  console.log();
  console.log(chalk.yellow('  ● Project instructions support:'));
  for (const tool of groupedTools[SKILLS_SUPPORT.AGENTS]) {
    console.log(`    ${tool.id.padEnd(15)} ${tool.name}`);
  }

  console.log();
  console.log(chalk.gray('  ○ Basic support:'));
  for (const tool of groupedTools[SKILLS_SUPPORT.BASIC]) {
    console.log(`    ${tool.id.padEnd(15)} ${tool.name}`);
  }

  console.log();
  console.log(chalk.cyan('Examples:'));
  console.log('  devbooks init                        # interactive init');
  console.log('  devbooks init my-project             # init in my-project');
  console.log('  devbooks init --tools claude,cursor  # non-interactive');
  console.log('  devbooks update                      # update configured tools');
}

// ============================================================================
// Main entry
// ============================================================================

async function main() {
  const args = process.argv.slice(2);

  // Parse args
  let command = null;
  let projectPath = null;
  const options = {};

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];

    if (arg === '-h' || arg === '--help') {
      showHelp();
      process.exit(0);
    } else if (arg === '--tools') {
      options.tools = args[++i];
    } else if (!arg.startsWith('-')) {
      if (!command) {
        command = arg;
      } else if (!projectPath) {
        projectPath = arg;
      }
    }
  }

  // Determine project directory
  const projectDir = projectPath ? path.resolve(projectPath) : process.cwd();

  // Execute command
  try {
    if (command === 'init' || !command) {
      await initCommand(projectDir, options);
    } else if (command === 'update') {
      await updateCommand(projectDir);
    } else {
      console.log(chalk.red(`Unknown command: ${command}`));
      showHelp();
      process.exit(1);
    }
  } catch (error) {
    if (error.name === 'ExitPromptError') {
      console.log(chalk.yellow('\nCancelled.'));
      process.exit(0);
    }
    throw error;
  }
}

main().catch(error => {
  console.error(chalk.red('✗'), error.message);
  process.exit(1);
});
