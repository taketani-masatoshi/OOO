"""Create a disposable source copy and reproduce synthetic audit observations."""
from pathlib import Path
import subprocess
import shutil
import sys

here = Path(__file__).resolve().parent
output = subprocess.check_output([sys.executable, str(here / 'prepare-audit.py')], text=True)
root = Path(output.strip().splitlines()[-1])
if not str(root).startswith('/private/tmp/ooo-finance-audit-'):
    raise RuntimeError('Refusing an unexpected workspace')
for name in ['audit.setup.ts', 'vitest.observations.config.ts', 'vitest.annual-observations.config.ts', 'run-observations.py', 'run-annual-observations.py']:
    shutil.copy2(here / name, root / name)
shutil.copy2(here / 'audit-observations.test.ts', root / 'tests/audit-observations.test.ts')
shutil.copy2(here / 'annual-close-observations.test.ts', root / 'tests/annual-close-acceptance.test.ts')
print('Synthetic audit workspace:', root, flush=True)
for name in ['run-observations.py', 'run-annual-observations.py']:
    subprocess.run([sys.executable, str(root / name)], cwd=root, check=True)
