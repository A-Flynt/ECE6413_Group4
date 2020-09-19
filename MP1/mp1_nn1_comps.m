hidden_units_arr  =  [16, 32,  64,  96,  128,  196,  256, 512, 1024];

accuracy = [0.91310, 0.94670, 0.96560, 0.97350, 0.97770, 0.98060, 0.98130, 0.98270, 0.98580];

elapsed_time = [11.643489, 15.196150, 20.779159, 23.889601, 22.700033, 23.217832, 26.692104, 60.162507, 166.673190];

filters = [16, 32,  64,  128,  256, 512, 1024];

nn2_accur = [0.97100,0.98250,0.98790,0.98910,0.99060,0.98860,0.98940];

nn2_elap_t = [20.144131, 36.528347, 73.449858, 151.242617,455.517831,5808.127949, 8782.896923];

figure;
plot(hidden_units_arr, accuracy,'-x','MarkerEdgeColor', 'red','LineWidth',5);
title("Test Accuracy vs. Number of Hidden Units for MP1 Modified NN1")
xlabel("Number of Hidden Units");
ylabel("Test Accuracy");

txt = sprintf("Accuracy = %f at %d", nn2_accur(5), filters(5));
txt = "\leftarrow" + txt;
text(hidden_units_arr(7),accuracy(7), txt,'FontSize',14)

saveas(gcf,'Test Accuracy vs. Number of Hidden Units for MP1 Modified NN1.png')

figure;
plot(hidden_units_arr, elapsed_time,'-x','MarkerEdgeColor', 'red','LineWidth',5);
xlabel("Number of Hidden Units");
ylabel("Time Elapsed (seconds)");

title("Time to Train & Test vs. Number of Hidden Units for MP1 Modified NN1")
txt = sprintf("Time Elapsed = %f at %d", elapsed_time(5), filters(5));
txt = "\leftarrow" + txt;
text(hidden_units_arr(7),elapsed_time(7), txt,'FontSize',14)

saveas(gcf,'Time to Train & Test vs. Number of Hidden Units for MP1 Modified NN1.png')

figure;
plot(filters, nn2_elap_t, '-x','MarkerEdgeColor', 'red','LineWidth',5);
xlabel("Number of Filters");
ylabel("Time Elapsed (seconds)");

txt = sprintf("Time Elapsed = %0.2f at %d", nn2_elap_t(5), filters(5));
txt = "\leftarrow" + txt;
text( filters(5),nn2_elap_t(5),txt,'FontSize',14)


title("Time to Train & Test vs. Number of Filters for MP1 Modified NN2")

saveas(gcf,'Time to Train & Test vs. Number of Filters for MP1 Modified NN2.png')

figure;
plot(filters, nn2_accur ,'-x','MarkerEdgeColor', 'red','LineWidth',5);
title("Test Accuracy vs. Number of Filters for MP1 Modified NN2")
xlabel("Number of Filters");
ylabel("Test Accuracy");

txt = sprintf("Accuracy = %f at %d", nn2_accur(5), filters(5));
txt = "\leftarrow" + txt;
text(filters(5),nn2_accur(5), txt,'FontSize',14)

title("Test Accuracy vs. Number of Filters for MP1 Modified NN2")

saveas(gcf,'Test Accuracy vs. Number of Filters for MP1 Modified NN2.png')


