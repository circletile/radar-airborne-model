% name:     Airborne Radar Model - Tier/Trade #7 Analysis Module
% matver:   R2023b
% summary:  Provides graphical plots for UAVRadarModel_NoSyms under Tier/Trade #7 conditions.
%           This function/model is part of university coursework.
% author:   Chris Upchurch (chrisu@ucf.edu)

function trade7_pwr_and_tfa
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
    iter_qty = 32;

    %% Sweep pwr and pw
    sweep_pwr = linspace(0.1, 1000, iter_qty);
    sweep_tfa = linspace(0.1, 1000, iter_qty);

    results_pdet_nofm = zeros(iter_qty, iter_qty);
    results_t2cn_multi = zeros(iter_qty, iter_qty);
    results_dopp_pcsn = zeros(iter_qty, iter_qty);
    results_tfa_tspin_ratio = zeros(iter_qty, iter_qty);

    saved_tx_power_w = model0.tx_power_w;
    saved_t_fa_sec = model0.t_fa_sec;

    for idx_pwr = 1:iter_qty
        for idx_tfa = 1:iter_qty
            fprintf('iteration: %d of %d\n', (idx_pwr - 1) * iter_qty + (idx_tfa), iter_qty ^ 2);

            model0.tx_power_w = sweep_pwr(idx_pwr);
            model0.t_fa_sec = sweep_tfa(idx_tfa);

            results_pdet_nofm(idx_pwr, idx_tfa) = model0.worst_case_p_det_n_of_m;
            results_t2cn_multi(idx_pwr, idx_tfa) = model0.worst_case_tgt_to_clutter_noise_noncoh_multi_db;
            results_dopp_pcsn(idx_pwr, idx_tfa) = model0.worst_case_doppler_precision_hz;
            results_tfa_tspin_ratio(idx_pwr, idx_tfa) = model0.tfa_tspin_ratio;
        end
    end

    % Restore original config
    model0.tx_power_w = saved_tx_power_w;
    model0.t_fa_sec = saved_t_fa_sec;

    %% Generte Plots

    % Plot 1: Pdet_NofM
    figure;
    tiledlayout(1, 2);

    nexttile;
    [X, Y] = meshgrid(sweep_pwr, sweep_tfa);
    % Intentionally transposed from data capture b/c meshgrid/matlab is like that (row/col index priority swap)
    surf(X, Y, results_pdet_nofm.');
    hold on;
    Zslice1 = zeros(size(X, 1));
    Zslice1(Zslice1 == 0) = 0.55;
    surf_req = surf(X, Y, Zslice1, 'FaceColor', [0.4940 0.1840 0.5560], 'FaceAlpha', 0.5);
    Zslice2 = zeros(size(X, 1));
    Zslice2(Zslice2 == 0) = 0.95;
    surf_goal = surf(X, Y, Zslice2, 'FaceColor', 'green', 'FaceAlpha', 0.5);
    title('Pdet 2-of-4 vs. Tx Power and Tfa')
    % AXES LABELS CHECKED OK
    xlabel('Tx Power (W)');
    ylabel('Tfa (sec)');
    zlabel('Detection Probability - 2-of-4 (pct)');
    legend([surf_req, surf_goal], 'Requirement Threshold', 'Goal Threshold');

    nexttile;
    filter_linidx = find(results_pdet_nofm >= 0.55 & results_pdet_nofm < 0.95);
    [xfilter, yfilter] = ind2sub([iter_qty iter_qty], filter_linidx);
    scatter(sweep_pwr(xfilter), sweep_tfa(yfilter), [], [0.4940 0.1840 0.5560]);
    hold on;
    filter_linidx = find(results_pdet_nofm >= 0.95);
    [xfilter, yfilter] = ind2sub([iter_qty iter_qty], filter_linidx);
    scatter(sweep_pwr(xfilter), sweep_tfa(yfilter), [], 'green');
    title('Acceptable Tx Pwr and Tfa for Pdet 2-of-4')
    % AXES LABELS CHECKED OK
    xlabel('Tx Power (W)');
    ylabel('Tfa (sec)');
    legend('Meets Requirement', 'Meets Goal');

    % Plot 2: T/(C+N) per Look
    figure;
    tiledlayout(1, 2);

    nexttile;
    [X, Y] = meshgrid(sweep_pwr, sweep_tfa);
    % Intentionally transposed from data capture b/c meshgrid/matlab is like that (row/col index priority swap)
    surf(X, Y, results_t2cn_multi.');
    hold on;
    Zslice = zeros(size(X, 1));
    surf_req = surf(X, Y, Zslice, 'FaceColor', [0.4940 0.1840 0.5560], 'FaceAlpha', 0.5);
    title('T/(C+N) per Look vs. Tx Power and Tfa')
    % AXES LABELS CHECKED OK
    xlabel('Tx Power (W)');
    ylabel('Tfa (sec)');
    zlabel('T/(C+N) (dbW)');
    legend(surf_req, '0 dB Plane');

    nexttile;
    filter_linidx = find(results_t2cn_multi > 0);
    [xfilter, yfilter] = ind2sub([iter_qty iter_qty], filter_linidx);
    scatter(sweep_pwr(xfilter), sweep_tfa(yfilter), [], 'green');
    hold on;
    filter_linidx = find(results_t2cn_multi <= 0);
    [xfilter, yfilter] = ind2sub([iter_qty iter_qty], filter_linidx);
    scatter(sweep_pwr(xfilter), sweep_tfa(yfilter), [], 'red');
    title('Acceptable Tx Pwr and Tfa for T/(C+N)')
    % AXES LABELS CHECKED OK
    xlabel('Tx Power (W)');
    ylabel('Tfa (sec)');
    legend('Positive Ratio', 'Negative Ratio');

    % Plot 3: Doppler Precision
    figure;
    tiledlayout(1, 2);

    nexttile;
    [X, Y] = meshgrid(sweep_pwr, sweep_tfa);
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
    title('Doppler Precision vs. Tx Power and Tfa')
    % AXES LABELS CHECKED OK
    xlabel('Tx Power (W)');
    ylabel('Tfa (sec)');
    zlabel('Doppler Precision (Hz, log scale)');
    legend([surf_req, surf_goal], 'Requirement Threshold', 'Goal Threshold');

    nexttile;
    filter_linidx_req = find(results_dopp_pcsn < 700 & results_dopp_pcsn > 50);
    [xfilter_req, yfilter_req] = ind2sub([iter_qty iter_qty], filter_linidx_req);
    scatter(sweep_pwr(xfilter_req), sweep_tfa(yfilter_req), [], [0.9290 0.6940 0.1250]);
    hold on;
    filter_linidx_goal = find(results_dopp_pcsn <= 50);
    [xfilter_goal, yfilter_goal] = ind2sub([iter_qty iter_qty], filter_linidx_goal);
    scatter(sweep_pwr(xfilter_goal), sweep_tfa(yfilter_goal), [], 'Green');
    title('Acceptable Tx Power and Tfa for Doppler Precision < 700 Hz')
    % AXES LABELS CHECKED OK
    xlabel('Tx Power (W)');
    ylabel('Tfa (sec)');
    legend('Meets Requirement', 'Meets Goal');

    % Plot 4: Tfa/Tspin Ratio
    figure;
    tiledlayout(1, 2);

    nexttile;
    [X, Y] = meshgrid(sweep_pwr, sweep_tfa);
    % Intentionally transposed from data capture b/c meshgrid/matlab is like that (row/col index priority swap)
    surf(X, Y, results_tfa_tspin_ratio.');
    hold on;
    % set(gca, 'zscale', 'log');
    Zslice_req = zeros(size(X, 1));
    Zslice_req(Zslice_req == 0) = 10;
    surf_req = surf(X, Y, Zslice_req, 'FaceColor', [0.9290 0.6940 0.1250], 'FaceAlpha', 0.5);
    % Zslice_goal = zeros(size(X, 1));
    % Zslice_goal(Zslice_goal == 0) = 50;
    % surf_goal = surf(X, Y, Zslice_goal, 'FaceColor', 'Green', 'FaceAlpha', 0.5);
    title('Tfa/Tspin Ratio vs. Tx Power and Tfa')
    % AXES LABELS CHECKED OK
    xlabel('Tx Power (W)');
    ylabel('Tfa (sec)');
    zlabel('Tfa/Tspin (ratio)');
    legend(surf_req, 'Requirement Threshold');

    nexttile;
    filter_linidx_req = find(results_tfa_tspin_ratio >= 10);
    [xfilter_req, yfilter_req] = ind2sub([iter_qty iter_qty], filter_linidx_req);
    scatter(sweep_pwr(xfilter_req), sweep_tfa(yfilter_req), [], [0.9290 0.6940 0.1250]);
    hold on;
    title('Acceptable Tx Power and Tfa for Tfa/Tspin Ratio <= 10')
    % AXES LABELS CHECKED OK
    xlabel('Tx Power (W)');
    ylabel('Tfa (sec)');
    legend('Meets Requirement');

    debug_hold;

end

function debug_hold
    disp('debug_hold');
end
