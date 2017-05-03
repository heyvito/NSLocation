{
  'targets': [
    {
      'target_name': 'nslocation',
      'sources': [
        'src/lib.mm'
      ],
      'link_settings': {
        'libraries': [
          'CoreLocation.framework'
        ]
      }
    }
  ]
}
