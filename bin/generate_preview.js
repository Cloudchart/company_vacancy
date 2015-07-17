var page    = require('webpage').create()
var system  = require('system')


if (system.args.length != 3)
  phantom.exit()


page.viewportSize = {
  width: 1200,
  height: 400
}


page.open(system.args[1], function() {
  page.render(system.args[2]);
  phantom.exit();
})
