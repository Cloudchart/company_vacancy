// module.exports = addClass;

addClass = function addClass(existing, added) {
  if (!existing) return added;
  if (existing.indexOf(added) > -1) return existing;
  return existing + ' ' + added;
}

cc.module('plugins/react_tokeninput/add-class').exports = addClass;
