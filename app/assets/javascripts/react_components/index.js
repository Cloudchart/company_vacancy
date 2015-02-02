//= require_self
//= require ./mixins
//= require ./shared
//= require ./company/burn_rate

this.cc       || ( this.cc        = {} )
this.cc.react || ( this.cc.react  = {} )

// React.DOM
cc.module('react/dom').exports = React.DOM
