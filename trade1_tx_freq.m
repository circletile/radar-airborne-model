% name:     Airborne Radar Model - Tier/Trade #1 Analysis Module
% matver:   R2023b
% summary:  Provides graphical plots for UAVRadarModel_NoSyms under Tier/Trade #1 conditions.
%           This function/model is part of university coursework.
% author:   Chris Upchurch (chrisu@ucf.edu)

function trade1_tx_freq
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

    %% Sweep tx_freq
    results_range_azim_res = zeros(2, 3);
    results_dopp_pcsn = zeros(1, 3);
    results_pdet_1look = zeros(1, 3);
    results_swath = zeros(1, 3);
    results_twarn = zeros(1, 3);

    initial_tx_freq = model0.tx_freq_ghz;

    model0.tx_freq_ghz = 37;
    results_range_azim_res(2, 1) = model0.worst_case_pulse_rng_res_m;
    results_range_azim_res(1, 1) = model0.worst_case_pulse_azim_res_m;
    results_dopp_pcsn(1, 1) = model0.worst_case_doppler_precision_hz;
    results_pdet_1look(1, 1) = model0.worst_case_p_det_multi_pulse;
    results_swath(1, 1) = model0.swath_width_km;
    results_twarn(1, 1) = model0.t_warn_sec;

    model0.tx_freq_ghz = 90;
    results_range_azim_res(2, 2) = model0.worst_case_pulse_rng_res_m;
    results_range_azim_res(1, 2) = model0.worst_case_pulse_azim_res_m;
    results_dopp_pcsn(1, 2) = model0.worst_case_doppler_precision_hz;
    results_pdet_1look(1, 2) = model0.worst_case_p_det_multi_pulse;
    results_swath(1, 2) = model0.swath_width_km;
    results_twarn(1, 2) = model0.t_warn_sec;

    model0.tx_freq_ghz = 150;
    results_range_azim_res(2, 3) = model0.worst_case_pulse_rng_res_m;
    results_range_azim_res(1, 3) = model0.worst_case_pulse_azim_res_m;
    results_dopp_pcsn(1, 3) = model0.worst_case_doppler_precision_hz;
    results_pdet_1look(1, 3) = model0.worst_case_p_det_multi_pulse;
    results_swath(1, 3) = model0.swath_width_km;
    results_twarn(1, 3) = model0.t_warn_sec;

    model0.tx_freq_ghz = initial_tx_freq;

    %% Generte Plots
    % Plot 1: Pdet_1Look
    figure;
    tiledlayout(2, 3);

    nexttile;
    bar([37 90 150], results_range_azim_res(1, :));
    hold on;
    req_min = plot([0 200], [6 6], '--r', 'LineWidth', 2);
    title('Tx. Frequency vs Pulse Azimuth Resolution');
    xlabel('Tx. Freq. (GHz)');
    ylabel('Azim. Res. (m)');
    legend([req_min], 'Requirement Threshold');

    nexttile;
    bar([37 90 150], results_range_azim_res(2, :));
    hold on;
    req_min = plot([0 200], [6 6], '--r', 'LineWidth', 2);
    title('Tx. Frequency vs Pulse Range Resolution');
    xlabel('Tx. Freq. (GHz)');
    ylabel('Range Res. (m)');
    ylim([16.75 17.5])
    legend([req_min], 'Requirement Threshold (Offscale Low)');

    nexttile;
    bar([37 90 150], results_dopp_pcsn(1, :));
    hold on;
    goal_min = plot([0 200], [50 50], '--g', 'LineWidth', 2);
    title('Tx. Frequency vs Doppler Precision');
    xlabel('Tx. Freq. (GHz)');
    ylabel('Doppler Precision (Hz)');
    legend([goal_min], 'Goal Threshold (0 \leftrightarrow Line)');

    nexttile;
    bar([37 90 150], results_pdet_1look(1, :));
    hold on;
    req_min = plot([0 200], [0.55 0.55], '--r', 'LineWidth', 2);
    title('Tx. Frequency vs Probability of Detection per Look');
    xlabel('Tx. Freq. (GHz)');
    ylabel('Pdet/Look (prob)');
    legend([req_min], 'Requirement Threshold');

    nexttile;
    bar([37 90 150], results_swath(1, :));
    hold on;
    req_min = plot([0 200], [10 10], '--r', 'LineWidth', 2);
    title('Tx. Frequency vs Swath Width');
    xlabel('Tx. Freq. (GHz)');
    ylabel('Swath Width (km)');
    ylim([0 20]);
    legend([req_min], 'Requirement Threshold');

    nexttile;
    bar([37 90 150], results_twarn(1, :));
    hold on;
    req_min = plot([0 200], [10 10], '--r', 'LineWidth', 2);
    title('Tx. Frequency vs Warning Time');
    xlabel('Tx. Freq. (GHz)');
    ylabel('Twarn (sec)');
    ylim([0 125]);
    legend([req_min], 'Requirement Threshold');

    debug_hold;

end

function debug_hold
    disp('debug_hold');
end
