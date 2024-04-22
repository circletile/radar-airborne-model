This is an airborne radar model developed using MATLAB R2023b as part of university coursework. It has been forked from a private repo and sanitized for public consumption.

This code is provided as-is and is not guaranteed to work for your specific application.

The functions/objects you will most likely find to be useful are UAVRadarModel_NoSyms.m and compliance_diag_check.m.

The trade*.m functions are used to produce plots which correspond to the design iteration methodology submitted as part of gradable work.

The UAVRadarModel/UAVRadarModel_NoSyms class object constructors require symunit inputs as part of unit sanity checks. Subsequent property modifications to instantiated class objects do not accept symunits. This post-initialization behavior was not specifically intentional, but left as-is due to development time constraints. See the trade m-files for how to correctly perform model parameter changes sans symunits.

For the network/graph representation of the radar model, see the contents of the network_graph_model directory. You will need to install Cytoscape + the yFiles plugin to correctly view/interact with the .cys file that contains the network/graph constucts contsined within.

To install the Cytoscape yFiles plugin, open the .cys file or any of the sample files shown, then go to the 'Layout > yFiles Heirarchic Layout' drop-down menu option. Follow the instructions that appear.
