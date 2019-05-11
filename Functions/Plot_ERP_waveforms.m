function [ERP] = Plot_ERP_waveforms(ERP, n_chan, epoch_boundary, ar_rm_from_ch, set_name, output_folder_cur, plot_animation_flag)

ERP = pop_ploterps( ERP, [ 1 2],  ar_rm_from_ch:n_chan, 'AutoYlim', 'on', 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 6 6], 'ChLabel',...
    'on', 'FontSizeChan',  10, 'FontSizeLeg',  12, 'FontSizeTicks',  10, 'LegPos', 'bottom', 'Linespec', {'r-' , 'b-' }, 'LineWidth',  1, 'Maximize',...
    'on', 'Position', [ 103.714 16.0476 106.857 31.9048], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0, 'xscale',...
    [ epoch_boundary(1) epoch_boundary(2)   epoch_boundary(1):100:epoch_boundary(2)], 'YDir', 'normal' );

output_image_name = [output_folder_cur, set_name, '_ERP_waveforms.png'];
saveas(gcf, output_image_name)
close(gcf)

if plot_animation_flag
    output_animation_name = [output_folder_cur, 'Animation_', set_name, '.gif'];
    ERP = pop_scalplot( ERP,  1,  epoch_boundary(1):10:epoch_boundary(2) , 'Animated', 'on', 'Blc', 'pre', 'Colormap', 'jet', 'Compression', 'none', 'Electrodes', 'on',...
        'Filename', output_animation_name, 'FontName', 'Courier New', 'FontSize',  10,...
        'FPS',  5, 'Legend', 'bn-la', 'Maplimit', 'maxmin', 'Mapstyle', 'both', 'Maptype', '2D', 'Mapview', '+X', 'Plotrad',  0.55, 'Quality',  60,...
        'Value', 'insta', 'VideoIntro', 'erplab' );
end