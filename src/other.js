export function groupByAndSort(arr, groupByKey, sortByKey) {
  const grouped = arr.reduce((acc, obj) => {
    const fieldValue = obj[groupByKey] == null ? "root" : obj[groupByKey];

    if (!acc[fieldValue]) {
      acc[fieldValue] = [];
    }

    acc[fieldValue].push(obj);
    return acc;
  }, {});

  for (const key in grouped) {
    if (grouped.hasOwnProperty(key)) {
      grouped[key].sort((a, b) => {
        if (a[sortByKey] < b[sortByKey]) return -1;
        if (a[sortByKey] > b[sortByKey]) return 1;
        return 0;
      });
    }
  }

  return grouped;
}

export function focusPreviousClass(className, activeElement) {
  const elements = document.querySelectorAll(`.${className}`);
  // const activeElement = document.activeElement;

  let currentIndex = -1;
  elements.forEach((el, index) => {
    if (el === activeElement) {
      currentIndex = index;
    }
  });

  if (currentIndex > 0) {
    elements[currentIndex - 1].focus();
  } else {
    elements[0].focus();
  }
}

export function focusNextClass(className, activeElement) {
  const elements = document.querySelectorAll(`.${className}`);
  // const activeElement = document.activeElement;

  let currentIndex = -1;
  elements.forEach((el, index) => {
    if (el === activeElement) {
      currentIndex = index;
    }
  });

  if (currentIndex < elements.length - 1) {
    elements[currentIndex + 1].focus();
  } else {
    elements[elements.length - 1].focus();
  }
}
