import React from 'react';
import Tag from './tag'

export default ({id, title, body, tags}) => (
  <div key={id}>
    <p><span>{title}</span></p>
    {tags.map(({name}, index) => <Tag key={index} name={name} />)}
    <p>{body}</p>
  </div>
)
