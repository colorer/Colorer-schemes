project('demo', 'c', version: '1.0.0')

lib = dependency('glib-2.0', required: true)

executable(
  'demo',
  files('main.c'),
  dependencies: lib,
  install: true,
)

if get_option('tests')
  test('smoke', find_program('true'))
endif
