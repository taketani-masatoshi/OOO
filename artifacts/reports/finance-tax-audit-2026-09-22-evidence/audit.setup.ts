import { beforeEach } from "vitest";
import { cpSync, rmSync } from "node:fs";
import { join } from "node:path";
import { setTenantId } from "./src/lib/tenant.js";
import { clearOperatorsRegistryCacheForTests } from "./src/lib/org/operators.js";
beforeEach(() => {
 for (const id of ["_fixture-books", "demo"]) {
  rmSync(join(process.cwd(), "tenants", id), { recursive: true, force: true });
  cpSync(join(process.cwd(), ".audit-seeds/tenants", id), join(process.cwd(), "tenants", id), { recursive: true });
 }
 setTenantId("_fixture-books"); clearOperatorsRegistryCacheForTests();
});
