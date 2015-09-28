export function pluralize (count, singular, plural) {
  return `${count} ${count == 1 ? singular : plural}`;
}

export function truncate (content, size=230) {
  return content.length > size + 3 ? `${content.substring(0, size)}...` : content;
}
