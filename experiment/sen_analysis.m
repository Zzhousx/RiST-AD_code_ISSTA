clear;
clc;
alpha_values = [5,10,15,20,25]; 
beta_values = [0.1,0.3,0.5,0.7,0.9];  
acc_data_orl = [0.824451295111081	0.837435244445934	0.859387461046141	0.876039942365044	0.893696344201320
0.863148477029789	0.870535133867239	0.876404516972154	0.881893241296116	0.889730255001173
0.874700934892605	0.870322018563817	0.866905471969976	0.864846697718058	0.861163421907985
0.887096471534363	0.878141607747210	0.866711121536039	0.860825654257280	0.853558288375834
0.888556110310626	0.878889521830915	0.868812786918205	0.861619140166873	0.853798210635660
]*100;


[X, Y] = meshgrid(1:length(beta_values), 1:length(alpha_values));

figure('Position', [100, 100, 700, 550]); 
s = surf(X, Y, acc_data_orl);

shading interp; 
colormap('jet'); 
colorbar;
view(-45, 20);
set(gca, 'XTick', 1:length(beta_values), 'XTickLabel', beta_values);
set(gca, 'YTick', 1:length(alpha_values), 'YTickLabel', alpha_values);
set(gca, 'FontSize',13);
zlim([65, 95]);
xlabel('\alpha', 'FontSize', 18, 'FontWeight', 'bold');
ylabel('\tau', 'FontSize', 18, 'FontWeight', 'bold');
zlabel('APFDc ($\%$)', 'Interpreter', 'latex', 'FontSize', 21);
box on;
grid on;

set(gcf, 'PaperPositionMode', 'auto');
% exportgraphics(gca, 'sen_random.pdf', 'ContentType', 'vector');



