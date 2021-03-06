% Model for an ideal (massless and rigid) cable
% 
% Author        : Darwin LAU
% Created       : 2011
% Description	:
%	This is the simplest type of cable that is massless and rigid. It also
%	assumes a straight-line model between attachment points. As such, the
%	only parameters that govern the kinematics of the ideal cable are the
%	attachment locations of cables at each link.
classdef CableModelIdeal < CableModel     
    properties (Dependent)
        K
    end
    
    methods 
        function ck = CableModelIdeal(name, numLinks)
            ck@CableModel(name, numLinks);
        end
        
        function update(obj, bodyModel)
            update@CableModel(obj, bodyModel);
        end
        
        function value = get.K(~)
            % Ideal cables have infinite stiffness
            value = Inf;
        end
    end
    
    methods (Static)
        function c = LoadXmlObj(xmlobj, bodiesModel)
            % <cable_ideal> tag
            name = char(xmlobj.getAttribute('name'));
            attachRefString = char(xmlobj.getAttribute('attachment_reference'));
            assert(~isempty(attachRefString), 'Invalid <cable_ideal> XML format: attachment_reference field empty');
            if (strcmp(attachRefString, 'joint'))
                attachmentRef = CableAttachmentReferenceType.JOINT;
            elseif (strcmp(attachRefString, 'com'))
                attachmentRef = CableAttachmentReferenceType.COM;
            else
                error('Unknown cableAttachmentReference type: %s', attachRefString);
            end
            
            % Generate an ideal cable object
            c = CableModelIdeal(name, bodiesModel.numLinks);
            
            % <properties> tag
            propertiesObj = xmlobj.getElementsByTagName('properties').item(0);
            % <force_min>
            c.forceMin = str2double(propertiesObj.getElementsByTagName('force_min').item(0).getFirstChild.getData);
            % <force_max>
            c.forceMax = str2double(propertiesObj.getElementsByTagName('force_max').item(0).getFirstChild.getData);
%             % <force_error>
%             c.forceInvalid = str2double(propertiesObj.getElementsByTagName('force_error').item(0).getFirstChild.getData);
            
            % <attachments> tag
            attachmentObjs = xmlobj.getElementsByTagName('attachments').item(0).getElementsByTagName('attachment');
            assert(~isempty(name), 'No name specified for this cable');
            assert(attachmentObjs.getLength >= 2, sprintf('Not enough attachments for cable ''%s'': %d attachment(s) specified', name, attachmentObjs.getLength));
            % Beginning attachment of segment 1
            attachmentObj = attachmentObjs.item(0);
            sLink = str2double(attachmentObj.getElementsByTagName('link').item(0).getFirstChild.getData);
            sLoc = XmlOperations.StringToVector3(char(attachmentObj.getElementsByTagName('location').item(0).getFirstChild.getData));
            for a = 2:attachmentObjs.getLength
                attachmentObj = attachmentObjs.item(a-1);
                eLink = str2double(attachmentObj.getElementsByTagName('link').item(0).getFirstChild.getData);
                eLoc = XmlOperations.StringToVector3(char(attachmentObj.getElementsByTagName('location').item(0).getFirstChild.getData));
                
                c.addSegment(sLink, sLoc, eLink, eLoc, bodiesModel, attachmentRef);
                
                sLink = eLink;
                sLoc = eLoc;                
            end            
        end
    end
end

