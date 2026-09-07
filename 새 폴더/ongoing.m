function [P_stress, angles] = stress_to_principal(Sx, Sy, Sz, Sxy, Syz, Szx)
    % Step 1: Construct the stress tensor
    sigma = [Sx, Sxy, Szx;
             Sxy, Sy, Syz;
             Szx, Syz, Sz];

    % Step 2: Perform eigenvalue decomposition to find principal stresses and directions
    [V, D] = eig(sigma);  % V are the eigenvectors (principal directions), D are the eigenvalues (principal stresses)

    % Principal stresses
    P_stress = diag(D);  % Principal stresses are the diagonal values of matrix D

    % Step 3: Compute rotation angles from eigenvectors
    % Extract the eigenvectors corresponding to the principal directions
    v1 = V(:,1);  % Principal direction 1
    v2 = V(:,2);  % Principal direction 2
    v3 = V(:,3);  % Principal direction 3

    % Compute rotation angles in degrees (these are the angles between the principal axes and the original axes)
    theta_x = atan2d(v1(2), v1(1));
    % Angle with respect to x-axis
    theta_y = 90-atan2d(v2(3), v2(2));  % Angle with respect to y-axis

    % Store the angles in a vector
    angles = [theta_x, theta_y];

    % Display results
    fprintf('Principal Stresses:\n');
    disp(P_stress);
    fprintf('Rotation Angles (degrees):\n');
    disp(angles);
end
stress_to_principal(90,51.5,88.2,0,15,0)