$.noConflict();

jQuery(function(){
  init();
  Custom.init();
});

function init() {
  if (typeof Week === 'undefined') {
    Custom = {};
  }
  
  Custom.init = function() {
    jQuery("div.expand").live("click", function(){
      var me = jQuery(this);
      if(!this.hasClassName("disabled")) {
        if(me.text() == "+") {
            me.parent().parent().parent().find(".children").removeClass("hidden");
            me.html("-");
        } else {
            me.parent().parent().parent().find(".children").addClass("hidden");
            me.html("+");
        }
      }
    });
  }
}


