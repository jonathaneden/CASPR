classdef Spherical < Joint
    %SphericalXYZ Joint definition for a spherical joint with Euler angles
    %xyz         
    
    properties (Constant = true)
        numDofs = 3;
        numVars = 4;
        q_default = [1; 0; 0; 0];   % 0 angle rotation about z axis
        q_dot_default = [0; 0; 0];
        q_ddot_default = [0; 0; 0];
        q_lb = [-1; -Inf; -Inf; -Inf];
        q_ub = [1; Inf; Inf; Inf];
    end
    
    properties (Dependent)
        % Quaternion of orientation
        e0      % real component of quaternion
        e1      % imaginary component of quaternion
        e2      % imaginary component of quaternion
        e3      % imaginary component of quaternion
        
        % Derivatives (use angular velocity components)
        wx
        wy
        wz
    end
    
    methods        
        function update(obj, q, q_dot, q_ddot)
            if(isa(q, 'double') && norm(q) ~= 1)
                q_quat_norm = Quaternion(q(1), q(2), q(3), q(4)).normalise();
                assert(roundn(norm(q_quat_norm),-5) == 1, 'Invalid q, norm of quaternion orientation must equal to one.');
            else
                q_quat_norm = Quaternion(q(1), q(2), q(3), q(4));
            end
            update@Joint(obj, q_quat_norm.toVector(), q_dot, q_ddot);
        end
        
        function value = get.e0(obj)
            value = obj.GetE0(obj.q);
        end
        function value = get.e1(obj)
            value = obj.GetE1(obj.q);
        end
        function value = get.e2(obj)
            value = obj.GetE2(obj.q);
        end
        function value = get.e3(obj)
            value = obj.GetE3(obj.q);
        end
        
        function value = get.wx(obj)
            value = obj.GetWx(obj.q_dot);
        end
        function value = get.wy(obj)
            value = obj.GetWy(obj.q_dot);
        end
        function value = get.wz(obj)
            value = obj.GetWz(obj.q_dot);
        end
    end
    
    methods (Static)
        function R_pe = RelRotationMatrix(q)
            e0 = Spherical.GetE0(q);
            e1 = Spherical.GetE1(q);
            e2 = Spherical.GetE2(q);
            e3 = Spherical.GetE3(q);
            
            R_pe = Quaternion.ToRotationMatrix(Quaternion(e0, e1, e2, e3));
        end

        function r_rel = RelTranslationVector(~)
            r_rel = [0; 0; 0];
        end
        
        function S = RelVelocityMatrix(~)
            S = [zeros(3,3); eye(3, 3)];
        end
        
        function S_dot = RelVelocityMatrixDeriv(~, ~)
            S_dot = zeros(6, 3);
        end
        
        % TODO: To complete
        function [N_j,A] = QuadMatrix(~)
            N_j = zeros(Spherical.numDofs,Spherical.numDofs^2);
            A = zeros(6,Spherical.numDofs);
        end
        
        % Perform a simple first order integral
        function q = QIntegrate(q0, q_dot, dt)
            q0_quat = Quaternion(q0(1), q0(2), q0(3), q0(4));
            w_quat = Quaternion(0, q_dot(1), q_dot(2), q_dot(3));
            q_quat = q0_quat * exp(0.5*w_quat*dt);
            q = q_quat.toVector();
        end
        
        function [q, q_dot, q_ddot] = GenerateTrajectory(q_s, ~, ~, q_e, ~, ~, total_time, time_step)
            time = 0:time_step:total_time;
                        
            quat_0s = Quaternion(q_s(1), q_s(2), q_s(3), q_s(4));
            quat_0e = Quaternion(q_e(1), q_e(2), q_e(3), q_e(4));
                        
            [quat_sp, quat_sp_dot, quat_sp_ddot] = Quaternion.GenerateInterpolation(quat_0s, quat_0e, time);
            
            q = zeros(4, length(time));
            q_dot = zeros(3, length(time));
            q_ddot = zeros(3, length(time));
            
            for t = 1:length(time)
                q_0p = quat_sp(t)*quat_0s;
                q_0p_dot = quat_sp_dot(t)*quat_0s;
                                
                w_quat = 2*q_0p_dot*inv(q_0p);
                w_quat_d = 2*(quat_sp_ddot(t)*inv(q_0p) + q_0p_dot*inv(q_0p_dot));
                
                q(1,t) = q_0p.q0;
                q(2,t) = q_0p.q1;
                q(3,t) = q_0p.q2;
                q(4,t) = q_0p.q3;
                q_dot(1,t) = w_quat.q1;
                q_dot(2,t) = w_quat.q2;
                q_dot(3,t) = w_quat.q3;
                q_ddot(1,t) = w_quat_d.q1;
                q_ddot(2,t) = w_quat_d.q2;
                q_ddot(3,t) = w_quat_d.q3;
            end
        end
        
        % Get variables from the gen coordinates
        function e0 = GetE0(q)
            e0 = q(1);
        end
        function e1 = GetE1(q)
            e1 = q(2);
        end
        function e2 = GetE2(q)
            e2 = q(3);
        end
        function e3 = GetE3(q)
            e3 = q(4);
        end
        
        function wx = GetWx(q_dot)
            wx = q_dot(1);
        end
        function wy = GetWy(q_dot)
            wy = q_dot(2);
        end
        function wz = GetWz(q_dot)
            wz = q_dot(3);
        end
    end
end

