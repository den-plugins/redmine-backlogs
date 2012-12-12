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
    jQuery("div.expand-toggle").live("click", function(){
      var me = jQuery(this);
      if(!this.hasClassName("disabled")) {
        if(me.text() == "+") {
            me.parent().parent().parent().find(".children").removeClass("hidden");
            me.html("-");
            me.removeClass("expand");
            me.addClass("collapse");
        } else {
            me.parent().parent().parent().find(".children").addClass("hidden");
            me.html("+");
            me.addClass("expand");
            me.removeClass("collapse");
        }
      }

    });
    jQuery(".expand-collapse-all").live("click", function(){
      var me = jQuery(this);
      if(me.hasClass("expand")) {
        me.removeClass("expand").addClass("collapse");
        jQuery(".expand").each(function(index, value){
          jQuery("#"+value.id).click()
        });
      } else {
        me.removeClass("collapse").addClass("expand");
        jQuery(".collapse").each(function(index, value){
          jQuery("#"+value.id).click()
        });
      }
    });
  }
}

/*
 *
*/
