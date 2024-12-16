(binding
  attrpath: (attrpath
    attr: (identifier) @_identifier
    (#eq? @_identifier "url")
  )
  expression: (string_expression
    (string_fragment) @url
  )
)
