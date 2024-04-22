% name:     Airborne Radar Model - Tier/Trade #6 Analysis Module
% matver:   R2023b
% summary:  Provides graphical plots for UAVRadarModel_NoSyms under Tier/Trade #6 conditions.
%           This function/model is part of university coursework.
% author:   Chris Upchurch (chrisu@ucf.edu)

function trade6_scan_quant_on_tgt
    dbstop if error
    dbstop at debug_hold

    u = symunit;

    working_model_example = UAVRadarModel_NoSyms( ...
        'simultaneous', ...
        tx_freq = 90 * u.GHz, ...
        ant_altitude = 5 * u.km, ...
        ant_bs_grazing_ang_mid = 5 * u.deg, ...
        ant_dim_elev = 0.5 * u.m, ...
        ant_dim_azim = 0.5 * u.m, ...
        ant_spin_rate = 100 * u.rpm, ...
        ant_azim_fwd_look_half_angle = 45 * u.deg, ...
        tx_power = 500 * u.W, ...
        tx_pulse_width = 0.1 * u.usec, ...
        tx_prf = 100 * u.kHz, ...
        t_fa = 60 * u.sec, ...
        scan_qty_on_tgt_intent = 4, ...
        tx_pcr = 1); % not implemented; always use value of 

    % Convenience alias
    model0 = working_model_example;

    %% Sweeps
    sweep_scan_quant = 4:15;

    max_iter = length(sweep_scan_quant);

    results_min_spin_rate = zeros(max_iter, 1);
    results_dplr_tot = zeros(max_iter, 1);
    results_dopp_pcsn = zeros(max_iter, 1);

    % Backup initial config
    saved_scan_qty_on_tgt_intent = model0.scan_qty_on_tgt_intent;

    for idx_quant = 1:max_iter
        fprintf('iteration: %d\n', idx_quant);

        model0.scan_qty_on_tgt_intent = sweep_scan_quant(idx_quant);

        results_min_spin_rate(idx_quant) = model0.min_spin_rate_supported_rpm;
        results_dplr_tot(idx_quant) = model0.doppler_time_on_target_sec;
        results_dopp_pcsn(idx_quant) = model0.worst_case_doppler_precision_hz;
    end

    % Restore initial config
    model0.scan_qty_on_tgt_intent = saved_scan_qty_on_tgt_intent;

    %% Generte Plots
    % Plot 1: Min Spin Rate
    tiledlayout(2, 2);

    nexttile;
    bar(sweep_scan_quant, results_min_spin_rate)
    hold on;
    req_min = plot([4 15], [180 180], '--r', 'LineWidth', 2);
    title('Min Spin Rate Supported vs. Design Scans on Tgt Quantity')
    xlabel('Scans on Target');
    ylabel('Min Spin Rate (rpm)');
    legend(req_min, 'Requirement Threshold (Max)');

    % Plot 2: Doppler Time on Tgt
    nexttile;
    bar(sweep_scan_quant, results_dplr_tot)
    title('Doppler Time on Target vs. Design Scans on Tgt Quantity')
    xlabel('Scans on Target');
    ylabel('Doppler TOT (sec)');

    % Plot 3: Doppler Precision
    nexttile;
    bar(sweep_scan_quant, results_dopp_pcsn)
    hold on;
    set(gca, 'yscale', 'log');
    req_min = plot([4 15], [700 700], '--r', 'LineWidth', 2);
    goal_min = plot([4 15], [50 50], '--g', 'LineWidth', 2);
    title('Doppler Precision vs. Design Scans on Tgt Quantity')
    xlabel('Scans on Target');
    ylabel('Doppler Precision (Hz, log scale)');
    legend([req_min, goal_min], 'Requirement Threshold', 'Goal Threshold');

    debug_hold;

end

function debug_hold
    disp('debug_hold');
end
