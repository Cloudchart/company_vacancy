const DEVICE_IS_IPHONE = 'only screen and (min-device-width: 320px) and (max-device-width: 736px)';
const DEVICE_IS_IPAD = 'only screen and (min-device-width: 768px) and (max-device-width: 1024px)';
const ORIENTATION_IS_PORTRAIT = 'only screen and (orientation: portrait)';
const ORIENTATION_IS_LANDSCAPE = 'only screen and (orientation: landscape)';


export function deviceIs (name) {
  switch (name) {
    case 'iphone':
      return window.matchMedia(DEVICE_IS_IPHONE);
    case 'ipad':
      return window.matchMedia(DEVICE_IS_IPAD);
    default:
      throw new TypeError('Invalid name');
  }
}

export function orientationIs (name) {
  switch (name) {
    case 'p':
      return window.matchMedia(ORIENTATION_IS_PORTRAIT);
    case 'l':
      return window.matchMedia(ORIENTATION_IS_LANDSCAPE);
    default:
      throw new TypeError('Invalid name');
  }
}
