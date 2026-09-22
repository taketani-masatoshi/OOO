import os,subprocess,pathlib
root=str(pathlib.Path(__file__).parent)
env={k:v for k,v in os.environ.items() if not k.startswith(('ORGOS_','STEWARD_','WIRE_','STRIPE_','OPENAI_','ANTHROPIC_','OLLAMA_'))}
env.update(ORGOS_HOME=root,ORGOS_WORKSPACE=root,ORGOS_TENANT='_fixture-books',ORGOS_TEST_DISPOSABLE_ROOT=root,ORGOS_AUDIT_LOG=root+'/audit.jsonl',ORGOS_AUDIT_BRIDGE_DISABLED='1',ORGOS_LLM_MOCK='1',ORGOS_HUMAN_APPROVAL_STORE=root+'/human.json',ORGOS_STRIPE_SECRETS_FILE=root+'/stripe.env',NODE_ENV='test')
raise SystemExit(subprocess.call(['node','node_modules/vitest/vitest.mjs','run','--config','vitest.audit.config.ts','--reporter=default','--reporter=json','--outputFile.json=audit-results.json'],cwd=root,env=env))
