// Generated by ReScript, PLEASE EDIT WITH CARE


function isArchiveStatus(s) {
  switch (s) {
    case "ArchiveDone" :
    case "ArchiveReject" :
    case "ArchiveNoNeed" :
    case "Trash" :
        return true;
    default:
      return false;
  }
}

function statusToFloat(s) {
  switch (s) {
    case "TodoUrgent" :
        return 0;
    case "TodoHigh" :
        return 1;
    case "TodoMedium" :
        return 2;
    case "TodoLow" :
        return 3;
    case "LaterWill" :
        return 4;
    case "LaterMaybe" :
        return 5;
    case "LaterUnlikely" :
        return 6;
    case "LaterUnsorted" :
        return 7;
    case "ResolveDone" :
        return 8;
    case "ResolveReject" :
        return 9;
    case "ResolveNoNeed" :
        return 10;
    case "ArchiveDone" :
        return 11;
    case "ArchiveReject" :
        return 12;
    case "ArchiveNoNeed" :
        return 13;
    case "Trash" :
        return 14;
    
  }
}

function statusString(s) {
  switch (s) {
    case "TodoUrgent" :
        return "Todo: Urgent";
    case "TodoHigh" :
        return "Todo: High";
    case "TodoMedium" :
        return "Todo: Medium";
    case "TodoLow" :
        return "Todo: Low";
    case "LaterWill" :
        return "Later: Will Do";
    case "LaterMaybe" :
        return "Later: Maybe";
    case "LaterUnlikely" :
        return "Later: Unlikely";
    case "LaterUnsorted" :
        return "Later: Unsorted";
    case "ResolveDone" :
        return "Resolve: Done";
    case "ResolveReject" :
        return "Resolve: Reject";
    case "ResolveNoNeed" :
        return "Resolve: No Need";
    case "ArchiveDone" :
        return "Archive: Done";
    case "ArchiveReject" :
        return "Archive: Reject";
    case "ArchiveNoNeed" :
        return "Archive: No Need";
    case "Trash" :
        return "Trash";
    
  }
}

function statusStringShort(s) {
  switch (s) {
    case "TodoUrgent" :
        return "!";
    case "TodoHigh" :
        return "1";
    case "TodoMedium" :
        return "2";
    case "TodoLow" :
        return "3";
    case "LaterWill" :
        return "A";
    case "LaterMaybe" :
        return "B";
    case "LaterUnlikely" :
        return "C";
    case "LaterUnsorted" :
        return "-";
    case "ResolveDone" :
    case "ArchiveDone" :
        return "✔︎";
    case "ResolveReject" :
    case "ArchiveReject" :
        return "🞫";
    case "ResolveNoNeed" :
    case "ArchiveNoNeed" :
        return "○";
    case "Trash" :
        return "T";
    
  }
}

export {
  isArchiveStatus ,
  statusToFloat ,
  statusString ,
  statusStringShort ,
}
/* No side effect */
