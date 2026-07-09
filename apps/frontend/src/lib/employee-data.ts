// Employee Directory data layer
// ---------------------------------------------------

export type EmployeeStatus = "Active" | "Probation" | "Notice Period" | "Inactive" | "On Leave";
export type ConfirmationStatus = "Active - Probation" | "Active" | "Resignation - Under Review" | "Resignation - Accepted" | "Inactive - After Onboarding";
export type ComplianceStatus = "Compliant" | "Pending" | "Non-Compliant";

export interface Employee {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  personalEmail: string;
  phone: string;
  altPhone: string;
  gender: string;
  dob: string;
  address: string;
  emergencyContact: string;
  maritalStatus: string;
  nationality: string;
  // org
  department: string;
  designation: string;
  role: string;
  reportingManager: string;
  businessUnit: string;
  workLocation: string;
  officeBranch: string;
  category: "Permanent - Bond" | "Permanent - Without Bond" | "Contract-based" | "Intern - Paid" | "Intern - Unpaid";
  team: string;
  // employment
  joiningDate: string;
  status: EmployeeStatus;
  confirmationStatus: ConfirmationStatus;
  probationStatus: string;
  experience: string;
  previousCompany: string;
  employmentType: string;
  contractType: string;
  bondStatus: string;
  noticePeriod: string;
  // site details & assets
  projectSite: "Onsite" | "Offsite";
  assetId: string;
  exitType: "NA" | "Resign" | "Absconded" | "Terminated" | "Suspension";
  exitReason: string;
  // skills
  education: string;
  skills: string[];
  certifications: string[];
  languages: string[];
  // kpi
  kpiScore: number;
  quarterlyKpi: number;
  annualRating: number;
  goalCompletion: number;
  attendance: number;
  reportingEfficiency: number;
  promotionReadiness: string;
  managerFeedback: string;
  // finance
  pan: string;
  bankAccount: string;
  salaryBand: string;
  pfUan: string;
  taxRegime: string;
  complianceStatus: ComplianceStatus;
  calendarOverrides?: Record<
    string,
    {
      type: "Working" | "W-OFF" | "Leave" | "Holiday";
      shift?: string;
      leaveType?: string;
      reason?: string;
    }
  >;
}

export const departments = [
  "Product",
  "Design",
  "Marketing",
  "Sales",
  "Finance",
  "Human Resources",
  "Operations",
  "Engineering",
];

export const designationsList = [
  "Engineering Manager",
  "Product Manager",
  "UX Designer",
  "Marketing Lead",
  "Sales Executive",
  "Finance Analyst",
  "HR Business Partner",
  "Software Engineer",
  "Senior Software Engineer",
  "Tech Lead",
  "DevOps Engineer",
  "QA Engineer",
  "Data Analyst",
  "Content Strategist",
  "Business Analyst",
];

export const employeeStatuses: EmployeeStatus[] = [
  "Active",
  "Probation",
  "Notice Period",
  "Inactive",
  "On Leave",
];

// ---- seed helpers ----
const firstNames = [
  "Priya","Vikram","Kavya","Aditya","Pooja","Manish","Anjali","Rahul",
  "Sneha","Arjun","Divya","Karthik","Meera","Suresh","Nandini","Rohan",
  "Swati","Amit","Isha","Deepak","Ritu","Sanjay","Ananya","Varun",
  "Lakshmi","Gaurav","Neha","Rajesh","Pallavi","Vivek","Shruti","Nikhil",
  "Tanya","Ashish","Bhavna","Manoj","Ritika","Pranav","Sonal","Harsh",
  "Nisha","Kunal","Preeti","Abhinav","Juhi","Sachin","Meenal","Tushar",
];
const lastNames = [
  "Reddy","Mehta","Verma","Malhotra","Reddy","Mehta","Verma","Sharma",
  "Kapoor","Singh","Nair","Iyer","Joshi","Kumar","Rao","Gupta",
  "Patil","Bhatia","Das","Chopra","Desai","Saxena","Pillai","Mishra",
  "Subramaniam","Thakur","Chauhan","Menon","Kulkarni","Sinha","Bansal","Agarwal",
  "Dubey","Patel","Tiwari","Deshpande","Chandra","Naidu","Jain","Shah",
  "Srinivasan","Mukherjee","Roy","Bhatt","Pandey","Tendulkar","Rathore","Dhawan",
];

const locations = ["Pune","Mumbai","Bengaluru","Delhi NCR","Hyderabad","Chennai","Remote"];
const branches = ["HQ Tower","Tech Park East","Tech Park West","Central Office","Innovation Hub"];
const businessUnits = ["Cloud Platform","Consumer Apps","Enterprise","Digital Commerce"];
const teams = ["Alpha","Beta","Gamma","Delta","Epsilon","Zeta","Theta","Omega"];
const categories = ["Permanent - Bond", "Permanent - Without Bond", "Contract-based", "Intern - Paid", "Intern - Unpaid"] as const;
const allSkills = ["React","TypeScript","Node.js","Python","AWS","Docker","Kubernetes","Figma","Snowflake","iOS","Java","Kafka","Go","GraphQL","Terraform","PostgreSQL"];
const allCerts = ["AWS Solutions Architect","Google Cloud Professional","PMP","Scrum Master","Kubernetes Admin","Azure Fundamentals","TOGAF","Six Sigma"];
const allLangs = ["English","Hindi","Tamil","Telugu","Kannada","Marathi","Bengali","Malayalam","Gujarati"];
const prevCompanies = ["Infosys","TCS","Wipro","HCL","Cognizant","Accenture","Deloitte","Capgemini","Mindtree","L&T Infotech","Oracle","SAP Labs","Google","Amazon","Microsoft"];
const mgrs = ["Rakesh Menon","Sunita Verma","David Thomas","Anu Krishnan","Mohit Bansal","Lakshmi Iyer","Priya Sharma","Rajesh Nair"];
const feedbacks = [
  "Consistently exceeds expectations. Strong leadership potential and excellent stakeholder management.",
  "Solid performer with good technical depth. Needs to improve cross-team collaboration.",
  "Shows great initiative and ownership. Ready for next-level responsibilities.",
  "Meets expectations. Recommended for advanced training programmes to accelerate growth.",
  "Exceptional problem-solving skills and mentoring ability. Key contributor to team success.",
  "Good performance overall. Should focus on documentation and knowledge sharing.",
  "Rising star in the team. Proactively identifies issues and drives solutions.",
  "Reliable team member with consistent output. Could benefit from broader exposure.",
];

function rng(seed: number): () => number {
  let s = seed;
  return () => { s = (s * 16807 + 11) % 2147483647; return s / 2147483647; };
}

export const employees: Employee[] = Array.from({ length: 48 }, (_, i) => {
  const rand = rng(i * 73 + 17);
  const r = () => rand();
  const pick = <T,>(arr: T[] | readonly T[]) => arr[Math.floor(r() * arr.length)];
  const pickN = <T,>(arr: T[], n: number) => {
    const copy = [...arr];
    const res: T[] = [];
    for (let j = 0; j < n && copy.length; j++) { const idx = Math.floor(r() * copy.length); res.push(copy.splice(idx, 1)[0]); }
    return res;
  };

  const firstName = firstNames[i];
  const lastName = lastNames[i];
  const dept = departments[i % departments.length];
  const desig = designationsList[i % designationsList.length];
  
  const projectSite = pick(["Onsite", "Offsite"]) as "Onsite" | "Offsite";
  const loc = projectSite === "Onsite" ? pick(["Andheri Office", "Dombivali Office"]) : pick(locations);
  const category = pick(categories);
  const assetId = pick([
    `TK-${1000 + Math.floor(r() * 9000)}`,
    `Client-${1000 + Math.floor(r() * 9000)}`,
    "None",
    "None"
  ]);
  
  const confirmationStatus = pick([
    "Active - Probation",
    "Active",
    "Resignation - Under Review",
    "Resignation - Accepted",
    "Inactive - After Onboarding"
  ]) as ConfirmationStatus;

  let status: EmployeeStatus = "Active";
  if (confirmationStatus === "Active - Probation") {
    status = "Probation";
  } else if (confirmationStatus === "Resignation - Under Review") {
    status = "Notice Period";
  } else if (confirmationStatus === "Resignation - Accepted") {
    status = pick(["Notice Period", "Inactive"]);
  } else if (confirmationStatus === "Inactive - After Onboarding") {
    status = "Inactive";
  } else {
    status = pick(["Active", "On Leave"]);
  }

  let exitType: "NA" | "Resign" | "Absconded" | "Terminated" | "Suspension" = "NA";
  let exitReason = "N/A";

  if (confirmationStatus === "Resignation - Under Review" || confirmationStatus === "Resignation - Accepted") {
    exitType = "Resign";
    exitReason = pick(["Personal reasons", "Better opportunities", "Career transition", "Higher studies"]);
  } else if (confirmationStatus === "Inactive - After Onboarding") {
    exitType = pick(["Absconded", "Terminated", "Suspension"]) as any;
    exitReason = exitType === "Terminated" 
      ? "Performance issues" 
      : exitType === "Suspension" 
      ? "Disciplinary action" 
      : "Did not report after onboarding";
  }

  const joinYear = 2019 + Math.floor(r() * 7);
  const joinMonth = String(1 + Math.floor(r() * 12)).padStart(2, "0");
  const joinDay = String(1 + Math.floor(r() * 28)).padStart(2, "0");
  const kpiScore = 55 + Math.floor(r() * 45);

  return {
    id: `EMP-${String(1001 + i)}`,
    firstName,
    lastName,
    email: `${firstName.toLowerCase()}.${lastName.toLowerCase()}@acmecorp.com`,
    personalEmail: `${firstName.toLowerCase()}${Math.floor(r() * 90 + 10)}@gmail.com`,
    phone: `+91 ${9000000000 + Math.floor(r() * 999999999)}`,
    altPhone: `+91 ${9000000000 + Math.floor(r() * 999999999)}`,
    gender: pick(["Male","Female","Other"]),
    dob: `${1985 + Math.floor(r() * 10)}-${String(1 + Math.floor(r() * 12)).padStart(2, "0")}-${String(1 + Math.floor(r() * 28)).padStart(2, "0")}`,
    address: `${100 + Math.floor(r() * 900)}, Sector ${Math.floor(r() * 30)}, ${loc}`,
    emergencyContact: `+91 ${9600000000 + Math.floor(r() * 399999999)}`,
    maritalStatus: pick(["Single","Married","Other"]),
    nationality: "Indian",
    department: dept,
    designation: desig,
    role: desig,
    reportingManager: pick(mgrs),
    businessUnit: pick(businessUnits),
    workLocation: loc,
    officeBranch: pick(branches),
    category,
    team: `Team ${pick(teams)}`,
    joiningDate: `${joinYear}-${joinMonth}-${joinDay}`,
    status,
    confirmationStatus,
    probationStatus: confirmationStatus === "Active - Probation" ? "In Progress" : "Completed",
    experience: `${1 + Math.floor(r() * 14)} years`,
    previousCompany: pick(prevCompanies),
    employmentType: category.includes("Intern") ? "Intern" : category.includes("Contract") ? "Contract" : "Full-time",
    contractType: category.includes("Contract") ? "Fixed Term" : "Permanent",
    bondStatus: category === "Permanent - Bond" ? "Yes — 2 years" : "No",
    noticePeriod: pick(["30 days","60 days","90 days"]),
    projectSite,
    assetId,
    exitType,
    exitReason,
    education: pick(["B.Tech Computer Science","M.Tech AI/ML","BBA","MBA Finance","B.Sc Statistics","M.Sc Data Science","B.E. Electronics","MCA"]),
    skills: pickN(allSkills, 3 + Math.floor(r() * 3)),
    certifications: pickN(allCerts, 1 + Math.floor(r() * 3)),
    languages: pickN(allLangs, 2 + Math.floor(r() * 3)),
    kpiScore,
    quarterlyKpi: 60 + Math.floor(r() * 40),
    annualRating: +(2.5 + r() * 2.5).toFixed(1),
    goalCompletion: 50 + Math.floor(r() * 50),
    attendance: 85 + Math.floor(r() * 15),
    reportingEfficiency: 70 + Math.floor(r() * 30),
    promotionReadiness: pick(["Ready Now","Ready in 6 months","Ready in 1 year","Not Yet"]),
    managerFeedback: pick(feedbacks),
    pan: `${String.fromCharCode(65 + Math.floor(r() * 26))}${String.fromCharCode(65 + Math.floor(r() * 26))}${String.fromCharCode(65 + Math.floor(r() * 26))}P${String.fromCharCode(65 + Math.floor(r() * 26))}${Math.floor(1000 + r() * 9000)}${String.fromCharCode(65 + Math.floor(r() * 26))}`,
    bankAccount: `XXXX-XXXX-${Math.floor(1000 + r() * 9000)}`,
    salaryBand: pick(["L3","L4","L5","L6","L7"]),
    pfUan: `1001${Math.floor(10000000 + r() * 90000000)}`,
    taxRegime: pick(["New Regime","Old Regime"]),
    complianceStatus: pick(["Compliant","Pending","Compliant","Compliant"]) as ComplianceStatus,
  };
});
