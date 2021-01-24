import React from 'react';

export default ({name, count, onClick}) => (
  <label onClick={e => onClick(e, name)}>{name}({count})</label>
)
