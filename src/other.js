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
