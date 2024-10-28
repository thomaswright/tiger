import React, { useRef } from "react";

const Import = ({ onImportJson }) => {
  let importJsonInputRef = useRef(null);

  return (
    <React.Fragment>
      <button
        className="bg-[var(--t2)] px-2 rounded text-xs flex flex-row items-center gap-1 h-5 "
        onClick={(event) => {
          event.preventDefault();
          importJsonInputRef.current.click();
        }}
      >
        Import
      </button>
      <input
        ref={importJsonInputRef}
        id={"jsonFileInput"}
        type="file"
        accept=".json"
        className="hidden"
        onChange={(event) => {
          const file = event.target.files[0];
          if (file) {
            const reader = new FileReader();
            reader.onload = function (e) {
              try {
                const jsonData = JSON.parse(e.target.result);

                onImportJson(jsonData);
              } catch (err) {
                output.textContent = "Error parsing JSON: " + err.message;
              }
            };
            reader.readAsText(file);
          }
        }}
      />
    </React.Fragment>
  );
};

export default Import;
