% name:     Airborne Radar Model - Tier/Trade #5 Analysis Module
% matver:   R2023b
% summary:  Provides graphical plots for UAVRadarModel_NoSyms under Tier/Trade #5 conditions.
%           This function/model is part of university coursework.
% author:   Chris Upchurch (chrisu@ucf.edu)

function trade5_prf_and_pw
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

    %% Set linspace range
    sample_limit = 32;

    %% Sweep pwr and pw
    sweep_prf = linspace(0.1 * 1e+03, 500 * 1e+03, sample_limit);
    sweep_pulse_width = linspace(0.001 * 1e-6, 0.5 * 1e-6, sample_limit);

    % Reqd
    % results_tfa_tspin_ratio = zeros(sample_limit, sample_limit); % unchanged in trade5
    results_duty = zeros(sample_limit, sample_limit);
    results_dopp_pcsn = zeros(sample_limit, sample_limit);
    results_pdet_multi = zeros(sample_limit, sample_limit);
    % results_pdet_nofm = zeros(sample_limit, sample_limit);

    % Not Reqd
    % results_range_res = zeros(sample_limit, sample_limit);
    results_t2cn_multi = zeros(sample_limit, sample_limit);

    saved_tx_prf_hz = model0.tx_prf_hz;
    saved_tx_pulse_width_sec = model0.tx_pulse_width_sec;

    for idx_prf = 1:sample_limit
        for idx_pulse_width = 1:sample_limit
            fprintf('iteration: %d of %d\n', (idx_prf - 1) * sample_limit + (idx_pulse_width), sample_limit ^ 2);

            model0.tx_prf_hz = sweep_prf(idx_prf);
            model0.tx_pulse_width_sec = sweep_pulse_width(idx_pulse_width);

            % results_tfa_tspin_ratio(idx_prf, idx_pulse_width) = model0.tfa_tspin_ratio; % unchanged in trade5
            results_duty(idx_prf, idx_pulse_width) = model0.tx_duty_cycle;
            results_dopp_pcsn(idx_prf, idx_pulse_width) = model0.worst_case_doppler_precision_hz;
            results_pdet_multi(idx_prf, idx_pulse_width) = model0.worst_case_p_det_multi_pulse;
            % results_pdet_nofm(idx_prf, idx_pulse_width) = model0.worst_case_p_det_n_of_m;

            % results_range_res(idx_prf, idx_pulse_width) = model0.worst_case_pulse_rng_res_m;
            results_t2cn_multi(idx_prf, idx_pulse_width) = model0.worst_case_tgt_to_clutter_noise_noncoh_multi_db;
        end
    end

    % Restore original config
    model0.tx_prf_hz = saved_tx_prf_hz;
    model0.tx_pulse_width_sec = saved_tx_pulse_width_sec;

    %% Generte Plots

    % Plot 1: Doppler Precision
    figure;
    tiledlayout(1, 2);

    nexttile;
    [X, Y] = meshgrid(sweep_prf, sweep_pulse_width);
    % Intentionally transposed from data capture b/c meshgrid/matlab is like that (row/col index priority swap)
    surf(X, Y, results_dopp_pcsn.');
    hold on;
    set(gca, 'zscale', 'log');
    Zslice_req = zeros(size(X, 1));
    Zslice_req(Zslice_req == 0) = 700;
    surf_req = surf(X, Y, Zslice_req, 'FaceColor', [0.9290 0.6940 0.1250], 'FaceAlpha', 0.5);
    Zslice_goal = zeros(size(X, 1));
    Zslice_goal(Zslice_goal == 0) = 50;
    surf_goal = surf(X, Y, Zslice_goal, 'FaceColor', 'Green', 'FaceAlpha', 0.5);
    title('Doppler Precision vs. PRF & Pulse Width')
    % AXES LABELS CHECKED OK
    xlabel('Tx PRF (Hz)');
    ylabel('Pulse Width (sec)');
    zlabel('Doppler Precision (Hz, log scale)');
    legend([surf_req, surf_goal], 'Requirement Threshold', 'Goal Threshold');

    nexttile;
    filter_linidx_req = find(results_dopp_pcsn < 700 & results_dopp_pcsn > 50);
    [xfilter_req, yfilter_req] = ind2sub([sample_limit sample_limit], filter_linidx_req);
    scatter(sweep_prf(xfilter_req), sweep_pulse_width(yfilter_req), [], [0.9290 0.6940 0.1250]);
    hold on;
    filter_linidx_goal = find(results_dopp_pcsn <= 50);
    [xfilter_goal, yfilter_goal] = ind2sub([sample_limit sample_limit], filter_linidx_goal);
    scatter(sweep_prf(xfilter_goal), sweep_pulse_width(yfilter_goal), [], 'Green');
    title('Acceptable PRF & Pulse Width for Doppler Precision < 700 Hz')
    % AXES LABELS CHECKED OK
    xlabel('Tx PRF (Hz)');
    ylabel('Pulse Width (sec)');
    legend('Meets Requirement', 'Meets Goal');

    % Plot 2: Duty Cycle
    figure;
    tiledlayout(1, 2);

    nexttile;
    [X, Y] = meshgrid(sweep_prf, sweep_pulse_width);
    % Intentionally transposed from data capture b/c meshgrid/matlab is like that (row/col index priority swap)
    surf(X, Y, results_duty.');
    hold on;
    Zslice1 = zeros(size(X, 1));
    Zslice1(Zslice1 == 0) = 0.04;
    surf_req_srch = surf(X, Y, Zslice1, 'FaceColor', 'red', 'FaceAlpha', 0.5);
    Zslice2 = zeros(size(X, 1));
    Zslice2(Zslice2 == 0) = 0.1;
    surf_req_dopp = surf(X, Y, Zslice2, 'FaceColor', [0.4940 0.1840 0.5560], 'FaceAlpha', 0.5);
    title('Duty Cycle vs. PRF and Pulse Width')
    % AXES LABELS CHECKED OK
    xlabel('Tx PRF (Hz)');
    ylabel('Pulse Width (sec)');
    zlabel('Duty Cycle (UNIT?)');
    legend([surf_req_srch, surf_req_dopp], 'Search Requirement Threshold', 'Doppler Requirement Threshold');

    nexttile;
    filter_linidx_srch = find(results_duty <= 0.4 & results_duty > 0.1);
    [xfilter, yfilter] = ind2sub([sample_limit sample_limit], filter_linidx_srch);
    scatter(sweep_prf(xfilter), sweep_pulse_width(yfilter), [], 'red');
    hold on;
    filter_linidx_dopp = find(results_duty <= 0.1);
    [xfilter, yfilter] = ind2sub([sample_limit sample_limit], filter_linidx_dopp);
    scatter(sweep_prf(xfilter), sweep_pulse_width(yfilter), [], [0.4940 0.1840 0.5560]);
    title('Acceptable PRF & Pulse Width for Duty Cycle')
    % AXES LABELS CHECKED OK
    xlabel('Tx PRF (Hz)');
    ylabel('Pulse Width (sec)');
    legend('Meets Search Mode Requirement', 'Meets Doppler Mode Requirement');

    % Plot 3: Pdet_1Look
    figure;
    tiledlayout(1, 2);

    nexttile;
    [X, Y] = meshgrid(sweep_prf, sweep_pulse_width);
    % Intentionally transposed from data capture b/c meshgrid/matlab is like that (row/col index priority swap)
    surf(X, Y, results_pdet_multi.');
    hold on;
    Zslice = zeros(size(X, 1));
    Zslice(Zslice == 0) = 0.55;
    surf_req = surf(X, Y, Zslice, 'FaceColor', [0.4940 0.1840 0.5560], 'FaceAlpha', 0.5);
    title('Pdet Single Look vs. PRF and Pulse Width')
    % AXES LABELS CHECKED OK
    xlabel('Tx PRF (Hz)');
    ylabel('Pulse Width (sec)');
    zlabel('Detection Probability - Single Look (pct)');
    legend(surf_req, 'Requirement Threshold');

    nexttile;
    filter_linidx = find(results_pdet_multi > 0.55);
    [xfilter, yfilter] = ind2sub([sample_limit sample_limit], filter_linidx);
    scatter(sweep_prf(xfilter), sweep_pulse_width(yfilter), [], [0.4940 0.1840 0.5560]);
    title('Acceptable PRF and PW. for Pdet Single Look >= 0.55')
    % AXES LABELS CHECKED OK
    xlabel('Tx PRF (Hz)');
    ylabel('Pulse Width (sec)');
    legend('Meets Requirement');

    % % Plot 4: Pdet_NofM
    % figure;
    % tiledlayout(1, 2);

    % nexttile;
    % [X, Y] = meshgrid(sweep_prf, sweep_pulse_width);
    % % Intentionally transposed from data capture b/c meshgrid/matlab is like that (row/col index priority swap)
    % surf(X, Y, results_pdet_nofm.');
    % hold on;
    % Zslice1 = zeros(size(X, 1));
    % Zslice1(Zslice1 == 0) = 0.55;
    % surf_req = surf(X, Y, Zslice1, 'FaceColor', [0.4940 0.1840 0.5560], 'FaceAlpha', 0.5);
    % Zslice2 = zeros(size(X, 1));
    % Zslice2(Zslice2 == 0) = 0.95;
    % surf_goal = surf(X, Y, Zslice2, 'FaceColor', 'green', 'FaceAlpha', 0.5);
    % title('Pdet 2-of-4 vs. PRF and Pulse Width')
    % % AXES LABELS CHECKED OK
    % xlabel('Tx PRF (Hz)');
    % ylabel('Pulse Width (sec)');
    % zlabel('Detection Probability - 2-of-4 (pct)');
    % legend([surf_req, surf_goal], 'Requirement Threshold', 'Goal Threshold');

    % nexttile;
    % filter_linidx = find(results_pdet_nofm >= 0.55 & results_pdet_nofm < 0.95);
    % [xfilter, yfilter] = ind2sub([sample_limit sample_limit], filter_linidx);
    % scatter(sweep_prf(xfilter), sweep_pulse_width(yfilter), [], [0.4940 0.1840 0.5560]);
    % hold on;
    % filter_linidx = find(results_pdet_nofm >= 0.95);
    % [xfilter, yfilter] = ind2sub([sample_limit sample_limit], filter_linidx);
    % scatter(sweep_prf(xfilter), sweep_pulse_width(yfilter), [], 'green');
    % title('Acceptable PRF and PW. for Pdet 2-of-4')
    % % AXES LABELS CHECKED OK
    % xlabel('Tx PRF (Hz)');
    % ylabel('Pulse Width (sec)');
    % legend('Meets Requirement', 'Meets Goal');

    % % Plot 5: Range Rez
    % figure;
    % tiledlayout(1, 2);

    % nexttile;
    % [X, Y] = meshgrid(sweep_prf, sweep_pulse_width);
    % % Intentionally transposed from data capture b/c meshgrid/matlab is like that (row/col index priority swap)
    % surf(X, Y, results_range_res.');
    % hold on;
    % Zslice1 = zeros(size(X, 1));
    % Zslice1(Zslice1 == 0) = 6;
    % surf_req = surf(X, Y, Zslice1, 'FaceColor', [0.4940 0.1840 0.5560], 'FaceAlpha', 0.5);
    % title('Range Resolution vs. PRF and Pulse Width')
    % % AXES LABELS CHECKED OK
    % xlabel('Tx PRF (Hz)');
    % ylabel('Pulse Width (sec)');
    % zlabel('Range Resolution (m)');
    % legend(surf_req, 'Requirement Threshold');

    % nexttile;
    % filter_linidx = find(results_range_res >= 6);
    % [xfilter, yfilter] = ind2sub([sample_limit sample_limit], filter_linidx);
    % scatter(sweep_prf(xfilter), sweep_pulse_width(yfilter), [], [0.4940 0.1840 0.5560]);
    % title('Acceptable PRF and PW. for Range Resolution')
    % % AXES LABELS CHECKED OK
    % xlabel('Tx PRF (Hz)');
    % ylabel('Pulse Width (sec)');
    % legend('Meets Requirement');

    % Plot 6: T/(C+N) per Look
    figure;
    tiledlayout(1, 2);

    nexttile;
    [X, Y] = meshgrid(sweep_prf, sweep_pulse_width);
    % Intentionally transposed from data capture b/c meshgrid/matlab is like that (row/col index priority swap)
    surf(X, Y, results_t2cn_multi.');
    hold on;
    Zslice = zeros(size(X, 1));
    surf_req = surf(X, Y, Zslice, 'FaceColor', [0.4940 0.1840 0.5560], 'FaceAlpha', 0.5);
    title('T/(C+N) per Look vs. PRF and Pulse Width')
    % AXES LABELS CHECKED OK
    xlabel('Tx PRF (Hz)');
    ylabel('Pulse Width (sec)');
    zlabel('T/(C+N) (dbW)');
    legend(surf_req, '0 dB Plane');

    nexttile;
    filter_linidx = find(results_t2cn_multi > 0);
    [xfilter, yfilter] = ind2sub([sample_limit sample_limit], filter_linidx);
    scatter(sweep_prf(xfilter), sweep_pulse_width(yfilter), [], 'green');
    hold on;
    filter_linidx = find(results_t2cn_multi <= 0);
    [xfilter, yfilter] = ind2sub([sample_limit sample_limit], filter_linidx);
    scatter(sweep_prf(xfilter), sweep_pulse_width(yfilter), [], 'red');
    title('Acceptable PRF and PW. for T/(C+N)')
    % AXES LABELS CHECKED OK
    xlabel('Tx PRF (Hz)');
    ylabel('Pulse Width (sec)');
    legend('Positive Value', 'Negative Value');

    debug_hold;

end

function debug_hold
    disp('debug_hold');
end
