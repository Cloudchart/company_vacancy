export function pluralize (count, singular, plural) {
  return `${count} ${count == 1 ? singular : plural}`;
}

export function truncate (content, size=200) {
  if (content.length < size + 3) {
    return content;
  }

  let raw = content.substring(0, size).split(' ').slice(0, -1).join(' ');

  return`${raw}...`;
}
