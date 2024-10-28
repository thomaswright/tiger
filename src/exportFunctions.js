import JSZip from "jszip";
import { format } from "date-fns";

function downloadBlob(blob, extension) {
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = `todos ${format(new Date(), "y-MM-dd")} at ${format(
    new Date(),
    "hh.mm.ss a"
  )}${extension}`;
  a.click();

  // Clean up
  setTimeout(() => {
    URL.revokeObjectURL(url);
  }, 0);
}

export function exportToFolder(arr) {
  const zip = new JSZip();
  const folder = zip.folder("megalog");

  arr.forEach(([name, content]) => {
    folder.file(name, content);
  });

  zip.generateAsync({ type: "blob" }).then(function (blob) {
    downloadBlob(blob, ".zip");
  });
}

export function exportToFile(fileContent) {
  const blob = new Blob([fileContent], { type: "text/plain" });
  downloadBlob(blob, ".txt");
}

export function exportToJsonFile(fileContent) {
  const blob = new Blob([fileContent], { type: "application/json" });
  downloadBlob(blob, ".json");
}
