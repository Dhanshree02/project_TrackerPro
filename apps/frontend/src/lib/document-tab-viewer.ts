import { getRepositoryPreviewUrl, type RepositoryItem } from "@/lib/api/repository";

/**
 * Opens any repository document (PDF, Word, Excel, PPT, Image, Text)
 * in a new browser tab for visual preview without triggering a download.
 */
export async function openDocumentInNewTab(doc: RepositoryItem) {
  const ext = doc.fileName.split(".").pop()?.toLowerCase() ?? "";
  const previewUrl = getRepositoryPreviewUrl(doc.id);

  // For native browser formats (PDF, Images)
  if (ext === "pdf" || ["png", "jpg", "jpeg", "webp", "gif", "svg"].includes(ext)) {
    window.open(previewUrl, "_blank", "noopener,noreferrer");
    return;
  }

  // Open the target window immediately to avoid popup blockers
  const newWindow = window.open("", "_blank");
  if (newWindow) {
    newWindow.document.write(`
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8"/>
          <title>Loading ${doc.fileName}...</title>
          <style>
            body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; display: flex; align-items: center; justify-content: center; height: 100vh; margin: 0; background: #0f172a; color: #f8fafc; }
            .loader-box { text-align: center; background: #1e293b; padding: 32px 48px; border-radius: 16px; border: 1px solid #334155; box-shadow: 0 10px 25px rgba(0,0,0,0.3); }
            .spinner { border: 3px solid #3b82f6; border-top-color: transparent; border-radius: 50%; width: 40px; height: 40px; animation: spin 0.8s linear infinite; margin: 0 auto 16px auto; }
            @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
          </style>
        </head>
        <body>
          <div class="loader-box">
            <div class="spinner"></div>
            <h3 style="margin: 0 0 6px 0; font-size: 17px; font-weight: 600;">Opening ${doc.fileName}</h3>
            <p style="margin: 0; color: #94a3b8; font-size: 13px;">Preparing in-browser view...</p>
          </div>
        </body>
      </html>
    `);
  }

  try {
    const res = await fetch(previewUrl);
    if (!res.ok) throw new Error("Failed to fetch document stream");
    const contentType = res.headers.get("content-type") || "";

    // If backend returned PDF stream (e.g. converted PPT or native PDF)
    if (contentType.includes("application/pdf")) {
      const blob = await res.blob();
      const pdfBlobUrl = URL.createObjectURL(blob);
      if (newWindow) {
        newWindow.location.href = pdfBlobUrl;
      } else {
        window.open(pdfBlobUrl, "_blank");
      }
      return;
    }

    const arrayBuffer = await res.arrayBuffer();

    // ── 1. PowerPoint Presentations -> Converted to Landscape PDF ────────────
    if (["pptx", "ppt", "pptm"].includes(ext)) {
      const JSZip = (await import("jszip")).default;
      const { jsPDF } = await import("jspdf");
      const zip = await JSZip.loadAsync(arrayBuffer);
      const slideFiles = Object.keys(zip.files).filter((path) =>
        /^ppt\/slides\/slide\d+\.xml$/i.test(path),
      );
      slideFiles.sort((a, b) => {
        const numA = parseInt(a.match(/\d+/)?.[0] || "0", 10);
        const numB = parseInt(b.match(/\d+/)?.[0] || "0", 10);
        return numA - numB;
      });

      const parsedSlides: { number: number; text: string[] }[] = [];
      for (let i = 0; i < slideFiles.length; i++) {
        const xmlContent = await zip.files[slideFiles[i]].async("text");
        const matches = xmlContent.match(/<a:t[^>]*>(.*?)<\/a:t>/gi) || [];
        const textLines = matches
          .map((m) => m.replace(/<[^>]+>/g, "").trim())
          .filter((t) => t.length > 0);
        parsedSlides.push({
          number: i + 1,
          text: textLines.length > 0 ? textLines : ["(Slide Presentation Graphic)"],
        });
      }

      if (parsedSlides.length === 0) {
        parsedSlides.push({ number: 1, text: [doc.fileName] });
      }

      const pdfDoc = new jsPDF({
        orientation: "landscape",
        unit: "pt",
        format: [960, 540],
      });

      const pageWidth = 960;
      const pageHeight = 540;

      parsedSlides.forEach((slide, idx) => {
        if (idx > 0) pdfDoc.addPage([pageWidth, pageHeight], "landscape");

        // Background
        pdfDoc.setFillColor(248, 250, 252);
        pdfDoc.rect(0, 0, pageWidth, pageHeight, "F");

        // Card Container
        pdfDoc.setFillColor(255, 255, 255);
        pdfDoc.setDrawColor(226, 232, 240);
        pdfDoc.roundedRect(30, 30, pageWidth - 60, pageHeight - 60, 8, 8, "FD");

        // Accent Bar
        pdfDoc.setFillColor(37, 99, 235);
        pdfDoc.rect(30, 30, pageWidth - 60, 6, "F");

        // Header info
        pdfDoc.setFont("helvetica", "bold");
        pdfDoc.setFontSize(11);
        pdfDoc.setTextColor(100, 116, 139);
        pdfDoc.text(doc.fileName, 50, 62);

        const badgeText = `SLIDE ${slide.number} OF ${parsedSlides.length}`;
        pdfDoc.setFontSize(10);
        pdfDoc.setTextColor(37, 99, 235);
        pdfDoc.text(badgeText, pageWidth - 50 - pdfDoc.getTextWidth(badgeText), 62);

        pdfDoc.setDrawColor(241, 245, 249);
        pdfDoc.line(50, 75, pageWidth - 50, 75);

        let currentY = 110;
        const contentLines = slide.text;
        if (contentLines.length > 0) {
          const titleText = contentLines[0];
          pdfDoc.setFont("helvetica", "bold");
          pdfDoc.setFontSize(22);
          pdfDoc.setTextColor(15, 23, 42);
          const splitTitle = pdfDoc.splitTextToSize(titleText, pageWidth - 100);
          pdfDoc.text(splitTitle, 50, currentY);
          currentY += splitTitle.length * 28 + 15;

          if (contentLines.length > 1) {
            pdfDoc.setFont("helvetica", "normal");
            pdfDoc.setFontSize(13);
            pdfDoc.setTextColor(51, 65, 85);
            for (let lineIdx = 1; lineIdx < contentLines.length; lineIdx++) {
              if (currentY > pageHeight - 70) break;
              const bodyText = contentLines[lineIdx];
              const splitBody = pdfDoc.splitTextToSize(bodyText, pageWidth - 130);
              pdfDoc.setFillColor(37, 99, 235);
              pdfDoc.circle(58, currentY - 4, 3, "F");
              pdfDoc.text(splitBody, 72, currentY);
              currentY += splitBody.length * 20 + 8;
            }
          }
        }

        pdfDoc.setFont("helvetica", "normal");
        pdfDoc.setFontSize(9);
        pdfDoc.setTextColor(148, 163, 184);
        pdfDoc.text("TrackerPro Repository — Presentation View", 50, pageHeight - 45);
        const pageIndicator = `Page ${slide.number} of ${parsedSlides.length}`;
        pdfDoc.text(pageIndicator, pageWidth - 50 - pdfDoc.getTextWidth(pageIndicator), pageHeight - 45);
      });

      const pdfBlob = pdfDoc.output("blob");
      const pdfBlobUrl = URL.createObjectURL(pdfBlob);
      if (newWindow) {
        newWindow.location.href = pdfBlobUrl;
      } else {
        window.open(pdfBlobUrl, "_blank");
      }
      return;
    }

    // ── 2. Word Documents -> Formatted Document Page ─────────────────────────
    if (["docx", "doc", "docm"].includes(ext)) {
      let htmlContent = "";
      try {
        const mammoth = await import("mammoth");
        const result = await mammoth.convertToHtml({ arrayBuffer });
        htmlContent = result.value;
      } catch {
        const textDecoder = new TextDecoder("utf-8");
        const rawText = textDecoder.decode(arrayBuffer);
        const printable = rawText.replace(/[^\x20-\x7E\t\n\r]/g, " ").trim();
        htmlContent = printable
          .replace(/&/g, "&amp;")
          .replace(/</g, "&lt;")
          .replace(/>/g, "&gt;")
          .replace(/\n/g, "<br/>");
      }

      const fullHtml = `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8"/>
  <title>${doc.fileName} — Word Preview</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; line-height: 1.6; color: #1e293b; background: #f8fafc; margin: 0; padding: 40px 20px; }
    .doc-page { max-width: 860px; margin: 0 auto; background: #ffffff; padding: 48px; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.06); border: 1px solid #e2e8f0; }
    h1, h2, h3, h4 { color: #0f172a; margin-top: 24px; margin-bottom: 12px; }
    table { width: 100%; border-collapse: collapse; margin: 20px 0; font-size: 14px; }
    th, td { border: 1px solid #cbd5e1; padding: 8px 12px; text-align: left; }
    th { background: #f1f5f9; font-weight: 600; }
    p { margin: 8px 0; }
    img { max-width: 100%; height: auto; border-radius: 6px; }
    .header-bar { display: flex; align-items: center; justify-content: space-between; border-bottom: 2px solid #e2e8f0; padding-bottom: 16px; margin-bottom: 32px; }
    .header-title { font-size: 20px; font-weight: 700; color: #2563eb; margin: 0; }
    .badge { background: #eff6ff; color: #1d4ed8; font-size: 12px; font-weight: 600; padding: 4px 10px; border-radius: 6px; border: 1px solid #bfdbfe; }
  </style>
</head>
<body>
  <div class="doc-page">
    <div class="header-bar">
      <h2 class="header-title">${doc.fileName}</h2>
      <span class="badge">Word Document Preview</span>
    </div>
    ${htmlContent || "<p>Document is empty.</p>"}
  </div>
</body>
</html>`;
      const blob = new Blob([fullHtml], { type: "text/html" });
      const blobUrl = URL.createObjectURL(blob);
      if (newWindow) {
        newWindow.location.href = blobUrl;
      } else {
        window.open(blobUrl, "_blank");
      }
      return;
    }

    // ── 3. Excel Spreadsheets -> Interactive Tabbed Data Grid ────────────────
    if (["xlsx", "xls", "xlsm", "xlsb", "csv"].includes(ext)) {
      const XLSX = await import("xlsx");
      const wb = XLSX.read(arrayBuffer, { type: "array" });
      const sheetNames = wb.SheetNames || [];
      const sheetsHtml = sheetNames
        .map((name, i) => {
          const ws = wb.Sheets[name];
          const tableHtml = XLSX.utils.sheet_to_html(ws);
          return `
          <div id="sheet-${i}" class="sheet-content ${i === 0 ? "active" : ""}">
            <div class="table-container">
              ${tableHtml}
            </div>
          </div>
        `;
        })
        .join("");

      const tabsHtml = sheetNames
        .map(
          (name, i) => `
        <button class="tab-btn ${i === 0 ? "active" : ""}" onclick="switchSheet(${i})">${name}</button>
      `,
        )
        .join("");

      const fullHtml = `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8"/>
  <title>${doc.fileName} — Excel Preview</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; margin: 0; background: #f8fafc; color: #1e293b; display: flex; flex-direction: column; height: 100vh; }
    .top-bar { background: #ffffff; border-bottom: 1px solid #e2e8f0; padding: 12px 24px; display: flex; align-items: center; justify-content: space-between; }
    .title { font-size: 16px; font-weight: 700; color: #0f172a; margin: 0; }
    .tabs-bar { background: #f1f5f9; border-bottom: 1px solid #e2e8f0; padding: 8px 24px 0 24px; display: flex; gap: 4px; overflow-x: auto; }
    .tab-btn { border: none; background: #e2e8f0; color: #475569; padding: 8px 16px; font-size: 13px; font-weight: 600; border-radius: 6px 6px 0 0; cursor: pointer; transition: all 0.15s ease; }
    .tab-btn.active { background: #ffffff; color: #059669; border-top: 2px solid #059669; }
    .sheet-container { flex: 1; overflow: auto; padding: 20px; }
    .sheet-content { display: none; }
    .sheet-content.active { display: block; }
    .table-container { background: #ffffff; border-radius: 8px; border: 1px solid #e2e8f0; overflow: auto; box-shadow: 0 1px 3px rgba(0,0,0,0.05); }
    table { width: 100%; border-collapse: collapse; font-size: 13px; }
    th, td { border: 1px solid #e2e8f0; padding: 8px 12px; white-space: nowrap; }
    th { background: #f8fafc; font-weight: 600; color: #475569; position: sticky; top: 0; }
    tr:nth-child(even) td { background: #fcfdfe; }
    tr:hover td { background: #f1f5f9; }
  </style>
  <script>
    function switchSheet(index) {
      document.querySelectorAll('.tab-btn').forEach((b, i) => b.classList.toggle('active', i === index));
      document.querySelectorAll('.sheet-content').forEach((s, i) => s.classList.toggle('active', i === index));
    }
  </script>
</head>
<body>
  <div class="top-bar">
    <h1 class="title">${doc.fileName}</h1>
    <span style="font-size: 12px; background: #ecfdf5; color: #047857; padding: 4px 10px; border-radius: 6px; font-weight: 600; border: 1px solid #a7f3d0;">Excel Preview</span>
  </div>
  <div class="tabs-bar">${tabsHtml}</div>
  <div class="sheet-container">${sheetsHtml}</div>
</body>
</html>`;
      const blob = new Blob([fullHtml], { type: "text/html" });
      const blobUrl = URL.createObjectURL(blob);
      if (newWindow) {
        newWindow.location.href = blobUrl;
      } else {
        window.open(blobUrl, "_blank");
      }
      return;
    }

    // ── 4. Fallback / Plain Text ─────────────────────────────────────────────
    if (newWindow) {
      newWindow.location.href = previewUrl;
    }
  } catch (err) {
    if (newWindow) {
      newWindow.document.body.innerHTML = `
        <div style="font-family: sans-serif; text-align: center; padding: 40px; color: #f8fafc;">
          <h3>Failed to open preview</h3>
          <p style="color: #94a3b8;">${err instanceof Error ? err.message : "Unable to load document."}</p>
        </div>
      `;
    }
  }
}
