/**
 * Skill type definitions for LLM agents.
 * Skills are markdown instruction files that guide agents through tasks.
 */

export enum SkillType {
  AUTO_INSTALL = 'auto-install',
  CODE_REVIEW = 'code-review',
  TEST_EVALUATION = 'test-evaluation',
  TEST_GENERATION = 'test-generation',
  SECURITY_AUDIT = 'security-audit',
  CODE_QUALITY_BOOSTER = 'code-quality-booster',
}

export enum Severity {
  CRITICAL = 'critical',
  HIGH = 'high',
  MEDIUM = 'medium',
  LOW = 'low',
  INFO = 'info',
}

export enum Verdict {
  EXCELLENT = 'excellent',
  GOOD = 'good',
  ACCEPTABLE = 'acceptable',
  POOR = 'poor',
  WORTHLESS = 'worthless',
}

export interface SkillTrigger {
  readonly patterns: readonly string[];
  readonly keywords: readonly string[];
}

export interface Finding {
  readonly file: string;
  readonly line: number;
  readonly severity: Severity;
  readonly category: string;
  readonly message: string;
  readonly suggestion?: string;
}

export interface CodeReviewResult {
  readonly file: string;
  readonly score: number;
  readonly verdict: Verdict;
  readonly criticalIssues: readonly Finding[];
  readonly warnings: readonly Finding[];
  readonly suggestions: readonly string[];
  readonly positiveNotes: readonly string[];
  readonly staticAnalysisSummary: StaticAnalysisSummary;
}

export interface StaticAnalysisSummary {
  readonly intellij: ToolSummary;
  readonly spotbugs: ToolSummary;
  readonly pmd: ToolSummary;
  readonly semgrep: ToolSummary;
}

export interface ToolSummary {
  readonly errors: number;
  readonly warnings: number;
  readonly findings: number;
}

export interface TestEvaluationResult {
  readonly file: string;
  readonly featureUnderTest: string;
  readonly totalTests: number;
  readonly lines: number;
  readonly scores: TestScores;
  readonly totalScore: number;
  readonly verdict: Verdict;
  readonly criticalIssues: readonly string[];
  readonly redFlags: readonly string[];
  readonly antiPatterns: readonly string[];
  readonly recommendations: readonly string[];
}

export interface TestScores {
  readonly realWorldRelevance: number;
  readonly mockingStrategy: number;
  readonly maintainability: number;
  readonly bugDetection: number;
}

export interface TestGenerationResult {
  readonly targetClass: string;
  readonly testFile: string;
  readonly totalTests: number;
  readonly coverageBefore: CoverageMetrics;
  readonly coverageAfter: CoverageMetrics;
  readonly boostingRounds: readonly BoostingRound[];
  readonly uncoveredReasons: readonly UncoveredReason[];
}

export interface CoverageMetrics {
  readonly line: number;
  readonly branch: number;
}

export interface BoostingRound {
  readonly round: number;
  readonly coverageDelta: number;
  readonly testsAdded: number;
  readonly description: string;
}

export interface UncoveredReason {
  readonly lines: string;
  readonly reason: string;
}

export interface SecurityAuditResult {
  readonly target: string;
  readonly scanDate: string;
  readonly riskLevel: Severity;
  readonly toolFindings: readonly SecurityToolFinding[];
  readonly owaspAssessment: readonly OwaspAssessment[];
  readonly recommendations: readonly string[];
}

export interface SecurityToolFinding {
  readonly tool: string;
  readonly critical: number;
  readonly high: number;
  readonly medium: number;
  readonly low: number;
}

export interface OwaspAssessment {
  readonly id: string;
  readonly name: string;
  readonly status: 'pass' | 'fail' | 'not-applicable';
  readonly notes: string;
}

export interface SkillDefinition {
  readonly type: SkillType;
  readonly name: string;
  readonly description: string;
  readonly triggers: SkillTrigger;
  readonly filePath: string;
}

export const SKILL_DEFINITIONS: readonly SkillDefinition[] = [
  {
    type: SkillType.AUTO_INSTALL,
    name: 'Auto Install',
    description: 'Automatically detect and install static analysis tools without Maven/Gradle',
    triggers: {
      patterns: ['setup *', 'install *', 'init tools'],
      keywords: ['setup', 'install', 'init', 'tools', 'dependencies'],
    },
    filePath: 'skills/auto-install.md',
  },
  {
    type: SkillType.CODE_REVIEW,
    name: 'Code Review',
    description: 'Review code quality with static analysis and AI semantic review',
    triggers: {
      patterns: ['review *', 'check *', 'code quality'],
      keywords: ['review', 'check', 'quality', 'bug', 'issue'],
    },
    filePath: 'skills/code-review.md',
  },
  {
    type: SkillType.TEST_EVALUATION,
    name: 'Test Evaluation',
    description: 'Evaluate test quality and meaningfulness',
    triggers: {
      patterns: ['evaluate test*', 'test quality', 'good test'],
      keywords: ['evaluate', 'test', 'quality', 'meaningful'],
    },
    filePath: 'skills/test-evaluation.md',
  },
  {
    type: SkillType.TEST_GENERATION,
    name: 'Test Generation',
    description: 'Generate unit tests with coverage boosting',
    triggers: {
      patterns: ['generate test*', 'write test*', 'increase coverage'],
      keywords: ['generate', 'write', 'test', 'coverage'],
    },
    filePath: 'skills/test-generation.md',
  },
  {
    type: SkillType.SECURITY_AUDIT,
    name: 'Security Audit',
    description: 'Security scan with OWASP Top 10 assessment',
    triggers: {
      patterns: ['security *', 'vulnerability *', 'owasp'],
      keywords: ['security', 'vulnerability', 'owasp', 'cve', 'audit'],
    },
    filePath: 'skills/security-audit.md',
  },
  {
    type: SkillType.CODE_QUALITY_BOOSTER,
    name: 'Code Quality Booster',
    description: 'AdaBoost-inspired iterative code quality analysis with multi-pass detection',
    triggers: {
      patterns: ['boost *', 'thorough review', 'deep check', 'comprehensive analysis'],
      keywords: ['boost', 'thorough', 'deep', 'comprehensive', 'iterate', 'quality'],
    },
    filePath: 'skills/code-quality-booster.md',
  },
] as const;
