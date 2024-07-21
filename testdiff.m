% Skript zur Berechnung der Ableitungen für v_orth

syms t
syms q11(t)
syms q12(t)
syms q13(t)
syms q21(t)
syms q22(t)
syms q23(t)

syms q11_dot(t)
syms q12_dot(t)
syms q13_dot(t)
syms q21_dot(t)
syms q22_dot(t)
syms q23_dot(t)

q11_dot = diff(q11(t),t);
q12_dot = diff(q12(t),t);
q13_dot = diff(q13(t),t);
q21_dot = diff(q21(t),t);
q22_dot = diff(q22(t),t);
q23_dot = diff(q23(t),t);


s_ortho = sqrt((q21(t)-q11(t))^2 + (q22(t)-q12(t))^2 + (q23(t)-q13(t))^2);

v_ortho = diff(s_ortho, t)

% e_Fc12 setzt sich aus den partiellen Ableitungen von v_ortho nach den
% generalisierten Geschwindigkeiten q_punkt zusammen

e_Fc12_1_1 = diff(v_ortho, q11_dot);
e_Fc12_1_2 = diff(v_ortho, q12_dot);
e_Fc12_1_3 = diff(v_ortho, q13_dot);
e_Fc12_2_1 = diff(v_ortho, q21_dot);
e_Fc12_2_2 = diff(v_ortho, q22_dot);
e_Fc12_2_3 = diff(v_ortho, q23_dot);


