vizmap = [ {
  "format_version" : "1.0",
  "generated_by" : "cytoscape-3.1.0",
  "target_cytoscapejs_version" : "~2.1",
  "title" : "markersAndTissues",
  "style" : [ {
    "selector" : "node",
    "css" : {
      "border-opacity" : 1.0,
      "text-valign" : "center",
      "text-halign" : "center",
      "border-color" : "rgb(102,102,102)",
      "shape" : "ellipse",
      "width" : 70.0,
      "border-width" : 3.5,
      "color" : "rgb(0,0,0)",
      "height" : 30.0,
      "background-color" : "rgb(255,255,255)",
      "text-opacity" : 1.0,
      "font-family" : "SansSerif",
      "font-weight" : "bold",
      "font-size" : 60,
      "text-valign" : "bottom",
      "background-opacity" : 1.0,
      "content" : "data(label)"
    }
  }, {
    "selector" : "node[degree > 300.0]",
    "css" : {
      "width" : 100.0
    }
  }, {
    "selector" : "node[degree = 300.0]",
    "css" : {
      "width" : 100.0
    }
  }, {
    "selector" : "node[degree > 10.0][degree < 300.0]",
    "css" : {
      "width" : "mapData(degree,10.0,300.0,50.0,100.0)"
    }
  }, {
    "selector" : "node[degree > 0.0][degree < 10.0]",
    "css" : {
      "width" : "mapData(degree,0.0,10.0,10.0,50.0)"
    }
  }, {
    "selector" : "node[degree = 0.0]",
    "css" : {
      "width" : 10.0
    }
  }, {
    "selector" : "node[degree < 0.0]",
    "css" : {
      "width" : 10.0
    }
  }, {
    "selector" : "node[degree > 300.0]",
    "css" : {
      "height" : 100.0
    }
  }, {
    "selector" : "node[degree = 300.0]",
    "css" : {
      "height" : 100.0
    }
  }, {
    "selector" : "node[degree > 10.0][degree < 300.0]",
    "css" : {
      "height" : "mapData(degree,10.0,300.0,50.0,100.0)"
    }
  }, {
    "selector" : "node[degree > 0.0][degree < 10.0]",
    "css" : {
      "height" : "mapData(degree,0.0,10.0,10.0,50.0)"
    }
  }, {
    "selector" : "node[degree = 0.0]",
    "css" : {
      "height" : 10.0
    }
  }, {
    "selector" : "node[degree < 0.0]",
    "css" : {
      "height" : 10.0
    }
  }, {
    "selector" : "node[nodeType = 'marker']",
    "css" : {
      "shape" : "ellipse"
    }
  }, {
    "selector" : "node[nodeType = 'tissue']",
    "css" : {
      "shape" : "roundrectangle"
    }
  }, {
    "selector" : "node:selected",
    "css" : {
      "background-color" : "rgb(255,255,0)"
    }
  }, {
    "selector" : "edge",
    "css" : {
      "target-arrow-color" : "rgb(0,0,0)",
      "source-arrow-shape" : "triangle",
      "target-arrow-shape" : "triangle",
      "source-arrow-color" : "rgb(0,0,0)",
      "color" : "rgb(0,0,0)",
      "line-style" : "solid",
      "line-color" : "rgb(255,255,255)",
      "text-opacity" : 1.0,
      "content" : "",
      "font-family" : "Dialog",
      "font-weight" : "normal",
      "font-size" : 10,
      "opacity" : 1.0,
      "width" : 3.0
    }
  }, {
    "selector" : "edge[edgeType = 'displays']",
    "css" : {
      "target-arrow-color" : "rgb(0,0,0)"
    }
  }, {
    "selector" : "edge[edgeType = 'displays']",
    "css" : {
      "source-arrow-shape" : "none"
    }
  }, {
    "selector" : "edge[edgeType = 'displays']",
    "css" : {
      "target-arrow-shape" : "none"
    }
  }, {
    "selector" : "edge[edgeType = 'displays']",
    "css" : {
      "source-arrow-color" : "rgb(0,0,0)"
    }
  }, {
    "selector" : "edge[edgeType = 'displays']",
    "css" : {
      "line-style" : "dashed"
    }
  }, {
    "selector" : "edge[edgeType = 'displays']",
    "css" : {
      "line-color" : "rgb(0,0,0)"
    }
  }, {
    "selector" : "edge[edgeType = 'displays']",
    "css" : {
      "width" : 1.0
    }
  }, {
    "selector" : "edge:selected",
    "css" : {
      "line-color" : "rgb(255,0,0)"
    }
  } ]
}, {
  "format_version" : "1.0",
  "generated_by" : "cytoscape-3.1.0",
  "target_cytoscapejs_version" : "~2.1",
  "title" : "default",
  "style" : [ {
    "selector" : "node",
    "css" : {
      "border-opacity" : 1.0,
      "content" : "",
      "text-valign" : "center",
      "text-halign" : "center",
      "border-color" : "rgb(102,102,102)",
      "shape" : "ellipse",
      "width" : 70.0,
      "border-width" : 1.5,
      "color" : "rgb(0,0,0)",
      "height" : 30.0,
      "background-color" : "rgb(255,255,255)",
      "text-opacity" : 1.0,
      "font-family" : "SansSerif",
      "font-weight" : "bold",
      "font-size" : 60,
      "background-opacity" : 1.0
    }
  }, {
    "selector" : "node:selected",
    "css" : {
      "background-color" : "rgb(255,255,0)"
    }
  }, {
    "selector" : "edge",
    "css" : {
      "target-arrow-color" : "rgb(0,0,0)",
      "source-arrow-shape" : "triangle",
      "target-arrow-shape" : "triangle",
      "source-arrow-color" : "rgb(0,0,0)",
      "color" : "rgb(0,0,0)",
      "line-style" : "solid",
      "line-color" : "rgb(255,255,255)",
      "text-opacity" : 1.0,
      "content" : "",
      "font-family" : "Dialog",
      "font-weight" : "normal",
      "font-size" : 10,
      "opacity" : 1.0,
      "width" : 1.0
    }
  }, {
    "selector" : "edge:selected",
    "css" : {
      "line-color" : "rgb(255,0,0)"
    }
  } ]
}, {
  "format_version" : "1.0",
  "generated_by" : "cytoscape-3.1.0",
  "target_cytoscapejs_version" : "~2.1",
  "title" : "Solid",
  "style" : [ {
    "selector" : "node",
    "css" : {
      "border-opacity" : 1.0,
      "text-valign" : "bottom",
      "text-halign" : "center",
      "border-color" : "rgb(0,0,0)",
      "shape" : "ellipse",
      "width" : 70.0,
      "border-width" : 0.0,
      "color" : "rgb(0,0,0)",
      "height" : 30.0,
      "background-color" : "rgb(102,102,102)",
      "text-opacity" : 0.6274509803921569,
      "font-family" : "Dialog",
      "font-weight" : "normal",
      "font-size" : 18,
      "background-opacity" : 1.0,
      "content" : "data(name)"
    }
  }, {
    "selector" : "node:selected",
    "css" : {
      "background-color" : "rgb(255,255,0)"
    }
  }, {
    "selector" : "edge",
    "css" : {
      "target-arrow-color" : "rgb(0,0,0)",
      "source-arrow-shape" : "none",
      "target-arrow-shape" : "none",
      "source-arrow-color" : "rgb(0,0,0)",
      "color" : "rgb(102,102,102)",
      "line-style" : "solid",
      "line-color" : "rgb(204,204,204)",
      "text-opacity" : 0.7450980392156863,
      "font-family" : "Dialog",
      "font-weight" : "normal",
      "font-size" : 10,
      "opacity" : 1.0,
      "width" : 12.0,
      "content" : "data(interaction)"
    }
  }, {
    "selector" : "edge:selected",
    "css" : {
      "line-color" : "rgb(255,0,0)"
    }
  } ]
}, {
  "format_version" : "1.0",
  "generated_by" : "cytoscape-3.1.0",
  "target_cytoscapejs_version" : "~2.1",
  "title" : "Sample1",
  "style" : [ {
    "selector" : "node",
    "css" : {
      "border-opacity" : 1.0,
      "text-valign" : "center",
      "text-halign" : "center",
      "border-color" : "rgb(0,0,0)",
      "shape" : "ellipse",
      "width" : 70.0,
      "border-width" : 0.0,
      "color" : "rgb(0,0,0)",
      "height" : 30.0,
      "background-color" : "rgb(204,204,255)",
      "text-opacity" : 1.0,
      "font-family" : "Dialog",
      "font-weight" : "bold",
      "font-size" : 12,
      "background-opacity" : 1.0,
      "content" : "data(name)"
    }
  }, {
    "selector" : "node:selected",
    "css" : {
      "background-color" : "rgb(255,255,0)"
    }
  }, {
    "selector" : "edge",
    "css" : {
      "target-arrow-color" : "rgb(0,0,0)",
      "source-arrow-shape" : "none",
      "target-arrow-shape" : "none",
      "source-arrow-color" : "rgb(0,0,0)",
      "color" : "rgb(0,0,0)",
      "line-style" : "solid",
      "line-color" : "rgb(0,0,0)",
      "text-opacity" : 1.0,
      "font-family" : "Dialog",
      "font-weight" : "normal",
      "font-size" : 10,
      "opacity" : 1.0,
      "width" : 1.0,
      "content" : "data(interaction)"
    }
  }, {
    "selector" : "edge[interaction = 'pd']",
    "css" : {
      "line-style" : "dashed"
    }
  }, {
    "selector" : "edge[interaction = 'pp']",
    "css" : {
      "line-style" : "solid"
    }
  }, {
    "selector" : "edge[interaction = 'pd']",
    "css" : {
      "line-color" : "rgb(255,0,51)"
    }
  }, {
    "selector" : "edge[interaction = 'pp']",
    "css" : {
      "line-color" : "rgb(0,204,0)"
    }
  }, {
    "selector" : "edge:selected",
    "css" : {
      "line-color" : "rgb(255,0,0)"
    }
  } ]
}, {
  "format_version" : "1.0",
  "generated_by" : "cytoscape-3.1.0",
  "target_cytoscapejs_version" : "~2.1",
  "title" : "Minimal",
  "style" : [ {
    "selector" : "node",
    "css" : {
      "border-opacity" : 1.0,
      "content" : "",
      "text-valign" : "center",
      "text-halign" : "center",
      "border-color" : "rgb(0,0,0)",
      "shape" : "rectangle",
      "width" : 70.0,
      "border-width" : 0.0,
      "color" : "rgb(0,0,0)",
      "height" : 30.0,
      "background-color" : "rgb(255,255,255)",
      "text-opacity" : 1.0,
      "font-family" : "Dialog",
      "font-weight" : "normal",
      "font-size" : 12,
      "background-opacity" : 1.0
    }
  }, {
    "selector" : "node:selected",
    "css" : {
      "background-color" : "rgb(255,255,0)"
    }
  }, {
    "selector" : "edge",
    "css" : {
      "target-arrow-color" : "rgb(0,0,0)",
      "source-arrow-shape" : "none",
      "target-arrow-shape" : "none",
      "source-arrow-color" : "rgb(0,0,0)",
      "color" : "rgb(0,0,0)",
      "line-style" : "solid",
      "line-color" : "rgb(51,51,51)",
      "text-opacity" : 1.0,
      "content" : "",
      "font-family" : "Dialog",
      "font-weight" : "normal",
      "font-size" : 10,
      "opacity" : 1.0,
      "width" : 4.0
    }
  }, {
    "selector" : "edge:selected",
    "css" : {
      "line-color" : "rgb(255,0,0)"
    }
  } ]
}, {
  "format_version" : "1.0",
  "generated_by" : "cytoscape-3.1.0",
  "target_cytoscapejs_version" : "~2.1",
  "title" : "Nested Network Style",
  "style" : [ {
    "selector" : "node",
    "css" : {
      "border-opacity" : 0.7450980392156863,
      "text-valign" : "center",
      "text-halign" : "center",
      "border-color" : "rgb(0,153,0)",
      "shape" : "ellipse",
      "width" : 70.0,
      "border-width" : 2.0,
      "color" : "rgb(0,0,0)",
      "height" : 30.0,
      "background-color" : "rgb(153,255,153)",
      "text-opacity" : 1.0,
      "font-family" : "SansSerif",
      "font-weight" : "normal",
      "font-size" : 13,
      "background-opacity" : 0.5882352941176471,
      "content" : "data(name)"
    }
  }, {
    "selector" : "node[has_nested_network = 'true']",
    "css" : {
      "width" : 60.0,
      "height" : 60.0
    }
  }, {
    "selector" : "node[has_nested_network = 'true']",
    "css" : {
      "text-valign" : "bottom"
    }
  }, {
    "selector" : "node[has_nested_network = 'true']",
    "css" : {
      "color" : "rgb(0,102,204)"
    }
  }, {
    "selector" : "node[has_nested_network = 'true']",
    "css" : {
      "border-width" : 5.0
    }
  }, {
    "selector" : "node[has_nested_network = 'true']",
    "css" : {
      "border-color" : "rgb(0,102,204)"
    }
  }, {
    "selector" : "node[has_nested_network = 'true']",
    "css" : {
      "background-color" : "rgb(255,255,255)"
    }
  }, {
    "selector" : "node[has_nested_network = 'true']",
    "css" : {
      "shape" : "rectangle"
    }
  }, {
    "selector" : "node:selected",
    "css" : {
      "background-color" : "rgb(255,255,0)"
    }
  }, {
    "selector" : "edge",
    "css" : {
      "target-arrow-color" : "rgb(0,0,0)",
      "source-arrow-shape" : "none",
      "target-arrow-shape" : "none",
      "source-arrow-color" : "rgb(0,0,0)",
      "color" : "rgb(0,0,0)",
      "line-style" : "solid",
      "line-color" : "rgb(51,51,51)",
      "text-opacity" : 1.0,
      "content" : "",
      "font-family" : "Dialog",
      "font-weight" : "normal",
      "font-size" : 10,
      "opacity" : 1.0,
      "width" : 2.0
    }
  }, {
    "selector" : "edge:selected",
    "css" : {
      "line-color" : "rgb(255,0,0)"
    }
  } ]
}, {
  "format_version" : "1.0",
  "generated_by" : "cytoscape-3.1.0",
  "target_cytoscapejs_version" : "~2.1",
  "title" : "Universe",
  "style" : [ {
    "selector" : "node",
    "css" : {
      "border-opacity" : 1.0,
      "text-valign" : "center",
      "text-halign" : "center",
      "border-color" : "rgb(0,0,0)",
      "shape" : "ellipse",
      "width" : 100.0,
      "border-width" : 0.0,
      "color" : "rgb(255,255,204)",
      "height" : 30.0,
      "background-color" : "rgb(0,0,0)",
      "text-opacity" : 0.7058823529411765,
      "font-family" : "Monospaced",
      "font-weight" : "bold",
      "font-size" : 20,
      "background-opacity" : 0.0,
      "content" : "data(name)"
    }
  }, {
    "selector" : "node:selected",
    "css" : {
      "background-color" : "rgb(255,255,0)"
    }
  }, {
    "selector" : "edge",
    "css" : {
      "target-arrow-color" : "rgb(0,0,0)",
      "source-arrow-shape" : "none",
      "target-arrow-shape" : "none",
      "source-arrow-color" : "rgb(0,0,0)",
      "color" : "rgb(0,0,0)",
      "line-style" : "dashed",
      "line-color" : "rgb(255,255,255)",
      "text-opacity" : 1.0,
      "content" : "",
      "font-family" : "Dialog",
      "font-weight" : "normal",
      "font-size" : 10,
      "opacity" : 0.39215686274509803,
      "width" : 3.0
    }
  }, {
    "selector" : "edge:selected",
    "css" : {
      "line-color" : "rgb(255,0,0)",
      "width" : 3.0
    }
  } ]
} ]