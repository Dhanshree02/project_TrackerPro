/**
 * WBS ID: IN-{FinancialYear}/{SubVentureId}/{ProjectId}
 * e.g. IN-2026-27/C013-01/P056
 */
export function composeWbsId(
  financialYear: string,
  subVentureCode: string,
  projectSeqId: string,
): string {
  return `IN-${financialYear}/${subVentureCode}/${projectSeqId}`;
}
