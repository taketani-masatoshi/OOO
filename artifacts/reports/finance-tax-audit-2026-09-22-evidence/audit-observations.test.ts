// Audit observations: assertions document current defects, not desired product behavior.
import { describe, it, expect } from "vitest";
import { writeFileSync, readFileSync, appendFileSync } from "node:fs";
import { join } from "node:path";
import YAML from "yaml";
import { appendJournalEntry, loadJournalEntries } from "../src/lib/finance/expense-claim-journal.js";
import { reverseJournalEntry } from "../src/lib/finance/journal-reverse.js";
import { buildConsumptionTaxSummary } from "../src/lib/finance/consumption-tax.js";
import { calculateSolePropIncomeTaxAmounts } from "../src/lib/finance/income-tax-policy.js";
import { computeAssetMonthlyDepreciation } from "../src/lib/finance/depreciation.js";
import { postAnnualPlTransfer } from "../src/lib/finance/annual-close.js";
import { buildTrialBalance } from "../src/lib/finance/ledger/trial-balance.js";
import { evaluateTaxAdjustment } from "../src/lib/finance/tax-adjustment.js";
import { buildElectronicLedgerComplianceReport } from "../src/lib/finance/ledger/electronic-ledger.js";
import { saveOpeningBalances, loadOpeningBalances } from "../src/lib/finance/ledger/opening-balance.js";
import { lockMonth } from "../src/lib/finance/period-lock.js";
import { postSalesInvoiceJournalEntry } from "../src/lib/finance/journal-sources.js";
import { computePayrollMonth, loadPayrollRates, computeWithholding } from "../src/lib/finance/payroll-jp.js";
import { getDataDir } from "../src/lib/utils.js";
import { resetFixtureJournalEntries, applyFixtureStatementRoles } from "./helpers/finance-fixture.js";
const record = (id: string, value: unknown) => appendFileSync("observations.jsonl", JSON.stringify({id, value})+"\n");
const dir = () => join(getDataDir(), "finance");
const entry = (id: string, lines: unknown[]) => ({entry_id:id, occurred_at:"2026-09-15T00:00:00.000Z", description:"Synthetic audit", source:{kind:"manual", authorized_by:"OP-AUDIT"}, evidence_refs:["synthetic:audit"],lines});
const line = (code: string, debit: number, credit: number, extra={}) => ({account_code:code,debit_yen:debit,credit_yen:credit,tax_category:"out_of_scope",...extra});
function post(id: string, lines: unknown[]) { return appendJournalEntry(entry(id,lines) as never); }

describe("adversarial accounting and tax observations", () => {
 it("C1: consumption tax adds an equal reversal instead of netting it", () => {
  resetFixtureJournalEntries();
  post("JE-SALE",[line("1100",10000,0),line("4100",0,10000,{tax_category:"taxable_10"})]);
  appendJournalEntry(reverseJournalEntry({entryId:"JE-SALE",occurredAt:"2026-09-16T00:00:00.000Z",authorizedBy:"OP-AUDIT"}));
  const tax=buildConsumptionTaxSummary({period:"2026-09"});
  record("C1",{expected_output_tax_yen:0,actual:tax.output_tax_yen}); expect(tax.output_tax_yen).toBe(2000);
 });
 it("C2: ledger corruption becomes a zero consumption-tax result", () => {
  resetFixtureJournalEntries(); writeFileSync(join(dir(),"journal-entries.yaml"),"entries: [broken");
  const tax=buildConsumptionTaxSummary({period:"2026-09"}); record("C2",tax); expect(tax.net_tax_yen).toBe(0);
 });
 it("C3: taxable fixed-asset purchases are omitted", () => {
  resetFixtureJournalEntries(); post("JE-ASSET",[line("1200",100000,0,{tax_category:"taxable_10",invoice_status:"qualified",purchase_use:"taxable_only",tax_amount_yen:10000}),line("2170",10000,0),line("1100",0,110000)]);
  const tax=buildConsumptionTaxSummary({period:"2026-09"}); record("C3",{expected_input_tax_yen:10000,actual:tax.input_tax_yen}); expect(tax.input_tax_yen).toBe(0);
 });
 it("C4: invoice status and non-taxable use do not change input credit", () => {
  resetFixtureJournalEntries(); post("JE-COST",[line("5900",10000,0,{tax_category:"taxable_10",invoice_status:"nonqualified_80",purchase_use:"non_taxable_only",tax_amount_yen:1000}),line("1100",0,10000)]);
  const tax=buildConsumptionTaxSummary({period:"2026-09"}); record("C4",{expected_input_tax_yen:0,actual:tax.input_tax_yen}); expect(tax.input_tax_yen).toBe(1000);
 });
 it("I1: rounding base income tax early changes final payable", () => {
  const result=calculateSolePropIncomeTaxAmounts({businessIncomeAfterBlueYen:149000,otherIncomeYen:0,deductionsYen:0,creditsYen:0,withholdingYen:0,prepaymentYen:0});
  record("I1",{expected_payable_yen:7600,actual:result}); expect(result).toMatchObject({ok:true,payable_yen:7500});
 });
 it("D1: fully depreciated assets still receive a full monthly charge", () => {
  const asset={id:"ASSET-999",name:"Synthetic",acquisition_cost:1200000,book_value:1,useful_life_years:1,placed_in_service_month:"2020-01",depreciation_method:"定額法"};
  const amount=computeAssetMonthlyDepreciation(asset as never,"2026-09"); record("D1",{book_value:1,monthly_charge:amount}); expect(amount).toBe(100000);
 });
 it("A1: annual transfer doubles an abnormal debit balance of revenue", () => {
  resetFixtureJournalEntries(); post("JE-RETURN",[line("4100",100,0),line("1100",0,100)]);
  const before=buildTrialBalance({asOf:"2026-09-30"}).rows.find(r=>r.account_code==="4100")?.balance_yen;
  postAnnualPlTransfer({fiscalYear:"FY2026",asOf:"2026-09-30"});
  const after=buildTrialBalance({asOf:"2026-09-30"}).rows.find(r=>r.account_code==="4100")?.balance_yen;
  record("A1",{before,after,expected_after:0}); expect(after).toBe(-200);
 });
 it("B1: invoice journal cannot satisfy its own AR counterparty guard", () => {
  resetFixtureJournalEntries(); let error="";
  try {postSalesInvoiceJournalEntry({invoiceId:"AUDIT-2026-09",amountYen:10000,occurredAt:"2026-09-15T00:00:00Z",authorizedBy:"OP-AUDIT"});} catch(e) {error=String(e);}
  record("B1",{error,journals:loadJournalEntries().entries.length}); expect(error).toContain("counterparty_id required");
 });
 it("E1: append-only compliance still passes after a balanced historical rewrite", () => {
  resetFixtureJournalEntries(); post("JE-OLD",[line("1100",100,0),line("4100",0,100)]);
  const file=loadJournalEntries(); file.entries[0]!.lines[0]!.debit_yen=900;file.entries[0]!.lines[1]!.credit_yen=900;
  writeFileSync(join(dir(),"journal-entries.yaml"),YAML.stringify(file));
  const report=buildElectronicLedgerComplianceReport();record("E1",report);expect(report.append_only_ok).toBe(true);expect(report.issues).toEqual([]);
 });
 it("O1: a locked month does not protect its opening balance", () => {
  resetFixtureJournalEntries(); lockMonth({month:"2026-09",lockedBy:"OP-AUDIT"});
  const opening=loadOpeningBalances()!; const before=buildTrialBalance({asOf:"2026-09-30"}).rows.find(r=>r.account_code==="1100")?.balance_yen;
  opening.lines=[{account_code:"1100",debit_yen:777,credit_yen:0},{account_code:"3100",debit_yen:0,credit_yen:777}]; saveOpeningBalances(opening);
  const after=buildTrialBalance({asOf:"2026-09-30"}).rows.find(r=>r.account_code==="1100")?.balance_yen;
  record("O1",{before,after,locked:true});expect(after).toBe(777);
 });
 it("T1: FY2026 high-income small corporate tax still uses 15 percent", () => {
  resetFixtureJournalEntries(); applyFixtureStatementRoles();
  const path=join(dir(),"tax-profile.yaml");const profile=YAML.parse(readFileSync(path,"utf8"));profile.corporate_tax={...profile.corporate_tax,capital_stock:1000000,category:"中小法人"};writeFileSync(path,YAML.stringify(profile));
  post("JE-BIG-SALE",[line("1100",1100000000,0),line("4100",0,1100000000)]);
  const sheet=evaluateTaxAdjustment("FY2026");record("T1",sheet);expect(sheet.can_compute).toBe(true);expect(sheet.corporate_tax_yen).toBe(254544000);
 });
 it("P1: payroll uses example rates and the same capped grade for high salaries", () => {
  const result=computePayrollMonth({month:"2026-09",grossYen:1000000}); record("P1",{rates_fiscal_year:loadPayrollRates().fiscal_year,result});expect(result.social_insurance.standard_remuneration_yen).toBe(350000);
 });
 it("P2: FY2026 withholding differs from the official computation with fixed social insurance", () => {
  const social=41300; const result=computeWithholding({grossYen:280000,socialEmployeeYen:social,dependents:0});
  const a=280000-social, deduction=Math.ceil(a*0.3+6667), base=48334;
  const expected=Math.round((a-deduction-base)*0.05105/10)*10;
  record("P2",{gross:280000,social_employee:41300,official_salary_deduction:deduction,official_basic_deduction:base,expected_withholding_yen:expected,actual:result});
  expect(expected).toBe(5720); expect(result.withholdingYen).toBe(4851);
 });

});
