// $.fn.extend ({
//   identify: function () {
//     var i = 0;
//     return this.each(function() {
//       if ($(this).attr('id')) return;
//       do {
//         i++;
//         var id = 'anonymous_element_' + i;
//       } while($('#' + id).length > 0);
//       $(this).attr('id', id);
//     });
//   }
// });
