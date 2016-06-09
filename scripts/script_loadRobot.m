% Script file to show how to simply load a robot
%
% Author        : Darwin LAU
% Created       : 2016
% Description    :

% Clear the variables, command window, and all windows
clear; clc; close all;

% Set up the type of model:
model_config = ModelConfig(ModelConfigType.M_SEGESTA);

% The XML objects from the model config are created
bodies_xmlobj = model_config.getBodiesPropertiesXmlObj();
cableset_xmlobj = model_config.getCableSetXmlObj(model_config.defaultCableSetId);

% Load the SystemKinematics object from the XML
cdpr = SystemModel.LoadXmlObj(bodies_xmlobj, cableset_xmlobj);
MotionSimulator.PlotFrame(cdpr, model_config.displayRange);
