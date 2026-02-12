# Auto Install Skill

## Trigger
- Trước khi chạy bất kỳ analysis skill nào
- User yêu cầu "setup", "install tools"
- Khi tool command fails với "command not found"

## Purpose
Tự động detect và cài đặt static analysis tools, không phụ thuộc Maven/Gradle.

---

## Step 1: Detect Environment

### 1.1 Detect OS
```bash
# Windows
echo %OS%

# Unix/Mac
uname -s
```

### 1.2 Detect Build Tool
```bash
# Check Maven
ls pom.xml 2>/dev/null && echo "MAVEN"

# Check Gradle
ls build.gradle* 2>/dev/null && echo "GRADLE"

# Check npm
ls package.json 2>/dev/null && echo "NPM"

# None = standalone
```

### 1.3 Detect Java Version
```bash
java -version 2>&1 | head -1
```

---

## Step 2: Install Tools

### 2.1 Semgrep (Cross-platform, no Java needed)

**Install:**
```bash
pip install semgrep
```

**IMPORTANT - Auto-detect semgrep path (LLM-friendly):**

Step 1: Check if semgrep works directly
```bash
semgrep --version
```

Step 2: If "command not found", find path using Python one-liner:
```bash
# Get Scripts directory path
python -c "import subprocess; r=subprocess.run(['pip','show','semgrep'],capture_output=True,text=True); loc=[l.split(': ',1)[1] for l in r.stdout.split('\n') if l.startswith('Location:')][0]; print(loc.replace('site-packages','Scripts'))"
```

Step 3: Add to PATH for current session:
```bash
# Bash/Git Bash (Windows) - run this ONCE at start of session
export PATH="$PATH:$(python -c "import subprocess;r=subprocess.run(['pip','show','semgrep'],capture_output=True,text=True);loc=[l.split(': ',1)[1] for l in r.stdout.split('\n') if l.startswith('Location:')][0];p=loc.replace('site-packages','Scripts').replace(chr(92),'/');print('/'+p[0].lower()+p[2:] if len(p)>1 and p[1]==':' else p)")"
```

```powershell
# PowerShell
$env:PATH += ";$(python -c "import subprocess;r=subprocess.run(['pip','show','semgrep'],capture_output=True,text=True);loc=[l.split(': ',1)[1] for l in r.stdout.split('\n') if l.startswith('Location:')][0];print(loc.replace('site-packages','Scripts'))")"
```

**Alternative - Use helper script:**
```bash
# Windows: scripts/find-semgrep.bat run --version
# Unix:    scripts/find-semgrep.sh run --version
```

**Verify:**
```bash
semgrep --version
# Expected: 1.151.0+
```

### 2.2 SpotBugs Standalone (No Maven needed)

**Download JAR directly:**
```bash
# Windows PowerShell
Invoke-WebRequest -Uri "https://github.com/spotbugs/spotbugs/releases/download/4.8.3/spotbugs-4.8.3.zip" -OutFile spotbugs.zip
Expand-Archive spotbugs.zip -DestinationPath ./tools/

# Unix/Mac
curl -L -o spotbugs.zip https://github.com/spotbugs/spotbugs/releases/download/4.8.3/spotbugs-4.8.3.zip
unzip spotbugs.zip -d ./tools/
```

**Run standalone:**
```bash
# Need compiled .class files
./tools/spotbugs-4.8.3/bin/spotbugs -textui -xml:withMessages -output spotbugs-report.xml ./target/classes/

# Or with JAR
java -jar ./tools/spotbugs-4.8.3/lib/spotbugs.jar -textui ./target/classes/
```

### 2.3 PMD Standalone (No Maven needed)

**Download:**
```bash
# Windows PowerShell
Invoke-WebRequest -Uri "https://github.com/pmd/pmd/releases/download/pmd_releases%2F7.0.0/pmd-dist-7.0.0-bin.zip" -OutFile pmd.zip
Expand-Archive pmd.zip -DestinationPath ./tools/

# Unix/Mac
curl -L -o pmd.zip https://github.com/pmd/pmd/releases/download/pmd_releases%2F7.0.0/pmd-dist-7.0.0-bin.zip
unzip pmd.zip -d ./tools/
```

**Run standalone (works on source code, no compilation needed!):**
```bash
# Windows
./tools/pmd-bin-7.0.0/bin/pmd.bat check -d ./src -R rulesets/java/quickstart.xml -f json

# Unix/Mac
./tools/pmd-bin-7.0.0/bin/pmd check -d ./src -R rulesets/java/quickstart.xml -f json
```

**Run CPD (Copy-Paste Detector - included in PMD):**
```bash
# Detect duplicate code - great for AI-generated code smell!
./tools/pmd-bin-7.0.0/bin/pmd.bat cpd --minimum-tokens 50 -d ./src --language java

# Supports 25+ languages: java, javascript, typescript, python, go, cpp, csharp, kotlin, swift...
./tools/pmd-bin-7.0.0/bin/pmd.bat cpd --minimum-tokens 50 -d ./src --language typescript
```

### 2.4 Checkstyle Standalone

**Download:**
```bash
curl -L -o checkstyle.jar https://github.com/checkstyle/checkstyle/releases/download/checkstyle-10.12.5/checkstyle-10.12.5-all.jar
```

**Run:**
```bash
java -jar checkstyle.jar -c /google_checks.xml ./src/
```

### 2.5 FindSecBugs (Security extension for SpotBugs)

**Download plugin:**
```bash
curl -L -o findsecbugs-plugin.jar https://repo1.maven.org/maven2/com/h3xstream/findsecbugs/findsecbugs-plugin/1.13.0/findsecbugs-plugin-1.13.0.jar

# Copy to SpotBugs plugin directory
cp findsecbugs-plugin.jar ./tools/spotbugs-4.8.3/plugin/
```

---

## Step 3: Create Tools Directory Structure

```bash
mkdir -p tools/{spotbugs,pmd,reports}
```

Recommended structure:
```
project/
├── tools/
│   ├── spotbugs-4.8.3/
│   ├── pmd-bin-7.0.0/
│   ├── checkstyle.jar
│   └── reports/
│       ├── spotbugs-report.xml
│       ├── pmd-report.json
│       └── semgrep-report.json
├── src/
└── ...
```

---

## Step 4: Quick Install Script

### Windows (PowerShell)
```powershell
# tools-install.ps1
$toolsDir = ".\tools"
New-Item -ItemType Directory -Force -Path $toolsDir

# Semgrep
pip install semgrep

# PMD (no Java compile needed!)
$pmdUrl = "https://github.com/pmd/pmd/releases/download/pmd_releases%2F7.0.0/pmd-dist-7.0.0-bin.zip"
Invoke-WebRequest -Uri $pmdUrl -OutFile "$toolsDir\pmd.zip"
Expand-Archive "$toolsDir\pmd.zip" -DestinationPath $toolsDir -Force
Remove-Item "$toolsDir\pmd.zip"

Write-Host "Tools installed!"
Write-Host "PMD: .\tools\pmd-bin-7.0.0\bin\pmd.bat check -d .\src -R rulesets/java/quickstart.xml -f json"
Write-Host "Semgrep: semgrep --config auto --json .\src"
```

### Unix/Mac (Bash)
```bash
#!/bin/bash
# tools-install.sh
TOOLS_DIR="./tools"
mkdir -p $TOOLS_DIR

# Semgrep
pip3 install semgrep

# PMD
curl -L -o $TOOLS_DIR/pmd.zip https://github.com/pmd/pmd/releases/download/pmd_releases%2F7.0.0/pmd-dist-7.0.0-bin.zip
unzip -o $TOOLS_DIR/pmd.zip -d $TOOLS_DIR
rm $TOOLS_DIR/pmd.zip

echo "Tools installed!"
echo "PMD: ./tools/pmd-bin-7.0.0/bin/pmd check -d ./src -R rulesets/java/quickstart.xml -f json"
echo "Semgrep: semgrep --config auto --json ./src"
```

---

## Step 5: Fallback Options

### If no Java at all → Use Semgrep only
Semgrep works on source code without compilation:
```bash
# Java rules
semgrep --config "p/java" --json ./src

# Security rules
semgrep --config "p/owasp-top-ten" --json ./src

# All auto rules
semgrep --config auto --json ./src
```

### If no pip → Use Docker
```bash
# Semgrep via Docker
docker run --rm -v "${PWD}:/src" returntocorp/semgrep semgrep --config auto /src

# PMD via Docker
docker run --rm -v "${PWD}:/src" pmd/pmd:latest check -d /src -R rulesets/java/quickstart.xml -f json
```

### If nothing works → Grep-based analysis
Basic pattern matching (last resort):
```bash
# Find potential SQL injection
grep -rn "\" + " --include="*.java" | grep -i "select\|insert\|update\|delete"

# Find hardcoded passwords
grep -rn "password\s*=" --include="*.java" | grep -v "getPassword\|setPassword"

# Find TODO/FIXME
grep -rn "TODO\|FIXME\|HACK\|XXX" --include="*.java"
```

---

## Tool Comparison (No Maven)

| Tool | Needs Java | Needs Compile | Install Method | Best For |
|------|------------|---------------|----------------|----------|
| Semgrep | No | No | pip install | Security, patterns |
| PMD | Yes (runtime) | No | curl + unzip | Code style, best practices |
| CPD | Yes (in PMD) | No | Included in PMD | Duplicate detection |
| SpotBugs | Yes | Yes (.class) | curl + unzip | Bug patterns |
| Checkstyle | Yes | No | curl jar | Code formatting |
| Grep patterns | No | No | Built-in | Basic search |

**Recommendation**: Start với **Semgrep + PMD (includes CPD)** - cả hai đều chạy trên source code, không cần compile.

---

## Auto-Detection Flow

```
1. Check if tool exists
   ├── Yes → Use it
   └── No → Try install
           ├── pip available → pip install semgrep
           ├── curl available → download standalone
           ├── docker available → use docker image
           └── None → use grep patterns (basic)

2. Check if compilation needed
   ├── SpotBugs needs .class files
   │   ├── Maven/Gradle available → mvn compile / gradle build
   │   └── Not available → skip SpotBugs, use PMD/Semgrep
   └── PMD/Semgrep work on source → no compile needed
```

---

## Tested Commands (Real-world)

Các commands đã được test thực tế:

### Semgrep (tested on Windows + Git Bash)
```bash
# Scan một folder với Java rules
semgrep --config "p/java" --json -o ./tools/reports/semgrep-report.json ./src/main/java/

# Scan với security rules
semgrep --config "p/owasp-top-ten" ./src/

# Expected output: "Ran X rules on Y files: Z findings"
```

### PMD (tested on Windows)
```bash
# Windows - dùng .bat
./tools/pmd-bin-7.0.0/bin/pmd.bat check -d ./src/main/java -R rulesets/java/quickstart.xml -f json -r ./tools/reports/pmd-report.json

# Unix/Mac
./tools/pmd-bin-7.0.0/bin/pmd check -d ./src/main/java -R rulesets/java/quickstart.xml -f json -r ./tools/reports/pmd-report.json

# Expected: Processing files 100% [...] Violations: XX, Errors: 0
```

### Sample PMD Output (37 violations on 15 files)
```json
{
  "files": [
    {
      "filename": "EWSpinWheelUseCaseImpl.java",
      "violations": [
        {"rule": "GuardLogStatement", "priority": 2, "description": "Logger calls should be surrounded by log level guards."},
        {"rule": "PackageCase", "priority": 3, "description": "Package name contains upper case characters"}
      ]
    }
  ]
}
```

---

## Output

After install, report:
```
## Tools Status

| Tool | Status | Version | Path |
|------|--------|---------|------|
| Semgrep | ✅ Installed | 1.151.0 | pip (check PATH on Windows) |
| PMD | ✅ Installed | 7.0.0 | ./tools/pmd-bin-7.0.0 |
| SpotBugs | ⚠️ Skipped | - | Needs compiled classes |
| Checkstyle | ✅ Installed | 10.12.5 | ./tools/checkstyle.jar |

Ready to run: Semgrep, PMD, Checkstyle
Not available: SpotBugs (no .class files)
```

---

## Troubleshooting

### "semgrep: command not found" (Windows)

**Quick fix - Add to PATH automatically:**
```bash
# Bash/Git Bash (Windows)
export PATH="$PATH:$(python -c "import subprocess;r=subprocess.run(['pip','show','semgrep'],capture_output=True,text=True);loc=[l.split(': ',1)[1] for l in r.stdout.split('\n') if l.startswith('Location:')][0];p=loc.replace('site-packages','Scripts').replace(chr(92),'/');print('/'+p[0].lower()+p[2:] if len(p)>1 and p[1]==':' else p)")"
```

```powershell
# PowerShell
$env:PATH += ";$(python -c "import subprocess;r=subprocess.run(['pip','show','semgrep'],capture_output=True,text=True);loc=[l.split(': ',1)[1] for l in r.stdout.split('\n') if l.startswith('Location:')][0];print(loc.replace('site-packages','Scripts'))")"
```

**Or use helper script:**
```bash
scripts/find-semgrep.bat run --version   # Windows
scripts/find-semgrep.sh run --version    # Unix
```

### "pmd.bat: command not found"
```bash
# Dùng full path
./tools/pmd-bin-7.0.0/bin/pmd.bat --version
```

### PMD "No rules found"
```bash
# Dùng built-in ruleset
-R rulesets/java/quickstart.xml   # Basic rules
-R rulesets/java/errorprone.xml   # Error-prone rules
-R category/java/bestpractices.xml # Best practices
```
