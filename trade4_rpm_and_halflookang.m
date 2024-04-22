% name:     Airborne Radar Model - Tier/Trade #4 Analysis Module
% matver:   R2023b
% summary:  Provides graphical plots for UAVRadarModel_NoSyms under Tier/Trade #4 conditions.
%           This function/model is part of university coursework.
% author:   Chris Upchurch (chrisu@ucf.edu)

function trade4_rpm_and_halflookang
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
    sweep_rpm = linspace(1, 180);

    % Sweep half look angle
    % NB1: This calculation fixes a negative discontinuity that was appearing
    %      in range resolution plots due to "HPBW overlap" at high grazing angles.
    % NB2: Adding eps to nudge the adjusted maximum just a bit above the overlap
    %       point, ensuting the minimum grazing angle w/r HPBW is < 90 degrees.
    % grz_ang_min_wr_hpbw_azim= 90 - (model0.ant_hpbw_azimuth_deg+ eps);
    % sweep_halflook_ang = linspace(2, grz_ang_max_wr_hpbw_elev);

    sweep_halflook_ang = linspace(0.1, 90);

    % results_range_res = zeros(100, 1);
    results_dopp_pcsn = zeros(100, 1);
    results_pdet_multi = zeros(100, 1);
    results_swath = zeros(100, 1);
    results_t2cn_multi = zeros(100, 1);

    % Backup initial config
    saved_ant_azim_fwd_look_half_angle_deg = model0.ant_azim_fwd_look_half_angle_deg;

    for idx_halflook = 1:100
        fprintf('hflflook iteration: %d\n', idx_halflook);

        model0.ant_azim_fwd_look_half_angle_deg = sweep_halflook_ang(idx_halflook);

        results_swath(idx_halflook) = model0.swath_width_km;
    end

    % Restore initial config
    model0.ant_azim_fwd_look_half_angle_deg = saved_ant_azim_fwd_look_half_angle_deg;

    % Backup initial config
    saved_ant_spin_rate_rpm = model0.ant_spin_rate_rpm;

    for idx_rpm = 1:100
        fprintf('rpm iteration: %d\n', idx_rpm);

        model0.ant_spin_rate_rpm = sweep_rpm(idx_rpm);

        % results_range_res(idx_rpm) = model0.worst_case_pulse_rng_res_m;
        results_dopp_pcsn(idx_rpm) = model0.worst_case_doppler_precision_hz;
        results_pdet_multi(idx_rpm) = model0.worst_case_p_det_multi_pulse;
        results_t2cn_multi(idx_rpm) = model0.tgt_to_clutter_noise_noncoh_multi_db_near;
    end

    % Restore initial config
    model0.ant_spin_rate_rpm = saved_ant_spin_rate_rpm;

    %% Generte Plots
    % Plot 1: Pdet_1Look
    tiledlayout(2, 2);

    nexttile;
    plot(sweep_rpm, results_pdet_multi)
    hold on;
    req_min = plot([0 sweep_rpm(100)], [0.55 0.55], '--r', 'LineWidth', 2);
    title('Pdet Single Look vs. Antenna RPM')
    xlabel('Ant. Rotaton (rpm)');
    ylabel('Detection Probability - Single Look (pct)');
    legend(req_min, 'Requirement Threshold');
    ylim([0 1.1]);

    % Plot 2: T/(C+N) Per Look
    nexttile;
    plot(sweep_rpm, results_t2cn_multi)
    % set(gca, 'yscale', 'log');
    title('T/(C+N) Single Look vs. Antenna RPM')
    xlabel('Ant. Rotaton (rpm)');
    ylabel('T(C+N) (dBW)');

    % Plot 3: Doppler Precision
    nexttile;
    plot(sweep_rpm, results_dopp_pcsn)
    hold on;
    req_min = plot([0 sweep_rpm(100)], [700 700], '--r', 'LineWidth', 2);
    goal_min = plot([0 sweep_rpm(100)], [50 50], '--g', 'LineWidth', 2);
    title('Doppler Precision vs. Antenna RPM')
    xlabel('Ant. Rotaton (rpm)');
    ylabel('Doppler Precision (Hz)');
    legend([req_min, goal_min], 'Requirement Threshold (Offscale High)', 'Goal Threshold');
    ylim([0 100]);

    % Plot 4: Swath Width
    nexttile;
    plot(sweep_halflook_ang, results_swath)
    hold on;
    req_min = plot([0 sweep_halflook_ang(100)], [10 10], '--r', 'LineWidth', 2);
    goal_min = plot([0 sweep_halflook_ang(100)], [100 100], '--g', 'LineWidth', 2);
    title({'Swath Width vs. RPM & Azim. Half-Look Sweep Ang.', '(Last opportunity to influence this parameter)'})
    xlabel('Ant. Half-Look Angle (deg)');
    ylabel('Swath Width (km)');
    legend([req_min, goal_min], 'Requirement Threshold', 'Goal Threshold (Offscale High)');
    ylim([0 20])

    debug_hold;

end

function debug_hold
    disp('debug_hold');
end
