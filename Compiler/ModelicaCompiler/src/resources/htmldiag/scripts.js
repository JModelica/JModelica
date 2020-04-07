var highlightedVarUses = new Set();

var currentColorSelectorTarget = null;
var currentColorSelectorCallback = null;

var colorSelector = $('<div id="colorSelector"></div>');
$(["tomato", "yellow", "wheat", "yellowGreen", "deepskyblue"]).each(function () {
    colorSelector.append('<span style="background:' + this + '"></span>');
});
colorSelector.children().on("click", function() {
    var color = $(this).css('background');
    if (currentColorSelectorTarget != null) {
        highlightVarUses(currentColorSelectorTarget, color);
        if (currentColorSelectorCallback != null) {
            currentColorSelectorCallback();
        }
    }
});

$(function () {
    $("span.collapsable").each(function () {
        var collapsable = $(this);
        var toggleButton = $("<div class=\"toggler\">...</div>").on("click", function (event) {
            collapsable.toggleClass("collapsed");
            collapsable.toggleClass("collapsable");
        });
        $(this).prepend(toggleButton);
    });
    
    $("[data-varDecl]").on("mouseover", function () {
        thiz = $(this);
        var name = thiz.attr("data-varDecl");
        var menu = thiz.children("div.nodeMenu").first();
        if (menu.size() == 0) {
            thiz.addClass("nodeWithMenu");
            var numUses = $("[data-varRef]").filter(function() {return $(this).attr('data-varRef') == name;}).size();
            menu = $("<div class=\"nodeMenu\">" + numUses + " uses on this page</div>").append('<br />');
            addHighlightLinksToMenu(menu, name);
            thiz.append(menu);
        }
        updateVarDeclMenu(name, menu);
    });
    $("[data-varRef]").on("mouseover", function () {
        thiz = $(this);
        var name = thiz.attr("data-varRef");
        var menu = thiz.children("div.nodeMenu").first();
        if (menu.size() == 0) {
            thiz.addClass("nodeWithMenu");
            menu = $("<div class=\"nodeMenu\">");
            addHighlightLinksToMenu(menu, name);
            thiz.append(menu);
        }
        updateVarDeclMenu(name, menu);
    });
});

function addHighlightLinksToMenu(menu, varName) {
    menu.append($("<span class=\"highlightLink\">Highlight uses</span>").on("mouseover", function () {
        selectColorFor(this, varName, function() {
            updateVarDeclMenu(varName, menu);
        });
    }));
    menu.append($("<a class=\"unhighlightLink\" href=\"javascript:void(0)\">Un-highlight uses</a>").on("click", function () {
        unhighlightVarUses(varName);
        updateVarDeclMenu(varName, menu);
    }));
}

function selectColorFor(node, name, callback) {
    currentColorSelectorTarget = name;
    currentColorSelectorCallback = callback;
    colorSelector.appendTo(node);
}

function updateVarDeclMenu( varName, menu) {
    if (highlightedVarUses.has(varName)) {
        menu.children(".highlightLink").hide();
        menu.children(".unhighlightLink").show();
    } else {
        menu.children(".highlightLink").show();
        menu.children(".unhighlightLink").hide();
    }
}

function highlightVarUses(name, color) {
    highlightedVarUses.add(name);
    var vars = $("[data-varRef]").filter(function () {
        return $(this).attr('data-varRef') == name;
    });
    vars.css("background", color);
}

function unhighlightVarUses(name) {
    highlightedVarUses.delete(name);
    var vars = $("[data-varRef]").filter(function () {
        return $(this).attr('data-varRef') == name;
    });
    vars.css("background", undefined);
}