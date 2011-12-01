// The MIT License
// 
// Copyright (c) 2009 Mark Maglana
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

/**************************************
              TASK CLASS
***************************************/

RBL.Task = Class.create(RBL.Item, {
  initialize: function($super, element, parentItem){
    this._prefix = "task_";
    this._parentItem = parentItem;
    
    if(element==null){
      element = $("item_template").down().cloneNode(true);
      element.writeAttribute({id: this._prefix + (new Date).getTime()});
      element.down("div.li_container").addClassName("task");
      element.down("div.li_container").removeClassName("maximized");
    }
    $super(element, this._prefix);
  },
  
  addTask: function(){
    // NOT IMPLEMENTED
  },
  
  getBacklogID: function(){
    return 0;
  },
  
  getParentItem: function(){
    return this._parentItem;
  },
  
  getParentID: function(){
    return this.getParentItem().getValue('.id');
  },
});

// Add class methods
Object.keys(RBL.ModelClassMethods).each(function(key){
  RBL.Task[key] = RBL.ModelClassMethods[key];
});
