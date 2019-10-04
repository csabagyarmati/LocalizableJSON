Pod::Spec.new do |s|
  s.name           = 'LocalizableJSON'
  s.version        = '1.1.0'
  s.summary        = 'A tool to generate localizable JSON file and compile to strings.'
  s.homepage       = 'https://github.com/csabagyarmati/LocalizableJSON'
  s.license        = { type: 'GNU', file: 'LICENSE' }
  s.author         = { 'Csaba Gyarmati' => 'csaba.gyarmati@gmail.com' }
  s.source         = { http: "#{s.homepage}/releases/download/#{s.version}/portable_LocalizableJSON.zip" }
  s.preserve_paths = '*'
  s.exclude_files  = '**/file.zip'
end