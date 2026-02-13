function pdxWidget() : pdxException() constructor {

}

function pdxWidgetTreeViewPair(key, value) : pdxWidget() constructor {
    self.key = key;
    self.value = value;
    
}

function pdxWidgetTreeView(title, depth = 0) : pdxWidget() constructor {
    self.name = title;
    self.depth = depth;
    self.items = [];
    
    static addItem = function(key, value) {
        var newItem = new pdxWidgetTreeViewPair(key, value);
        array_push(self.items, newItem);
        
        return newItem;
    }
    
    static addNode = function(title) {
        var newNode = new pdxWidgetTreeView(title, self.depth + 1);
        var newItem = new pdxWidgetTreeViewPair(title, newNode);
        array_push(self.items, newItem);
        
        return newNode;
    }
    
    static prettyPrint = function() {
        txt = "";
        if(self.depth == 0) {
            txt = /* "[" + string(self.depth) + "]" + */ string_repeat(" ", self.depth * TABSIZE) + self.name + "\n";
        }
        for(var _i=0, _n = array_length(self.items); _i<_n; _i++) {
            var _val = self.items[_i].value;
            if(typeof(_val) == "struct") {
                if(is_instanceof(_val, pdxWidgetTreeView)) {
                    txt += /* "[" + string(self.depth) + "]" + */ string_repeat(" ", (self.depth + 1) * TABSIZE) + self.items[_i].key + "\n";
                    txt += _val.prettyPrint();
                } else {
                    txt += string(_val) + "\n";
                }
            } else {
                txt += /* "[" + string(self.depth) + "]" + */ string_repeat(" ", (self.depth + 1) * TABSIZE) + self.items[_i].key + " = " + string(self.items[_i].value) + "\n";
            }
            
        }
        return txt;
    }
}

