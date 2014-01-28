@['companies#show'] = ->
    $ ->
        sticky $('.companies-wrapper article aside.blocks'),
            offset:
                top: $('body > header').outerHeight()
