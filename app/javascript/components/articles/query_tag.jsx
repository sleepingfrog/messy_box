import React from 'react';

export default ({name, onClick}) => (
  <label onClick={e => onClick(e, name)}>{name}</label>
)
