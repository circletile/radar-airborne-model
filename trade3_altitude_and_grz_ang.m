% name:     Airborne Radar Model - Tier/Trade #3 Analysis Module
% matver:   R2023b
% summary:  Provides graphical plots for UAVRadarModel_NoSyms under Tier/Trade #3 conditions.
%           This function/model is part of university coursework.
% author:   Chris Upchurch (chrisu@ucf.edu)

function trade3_altitude_and_grz_ang
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

    iter_qty = 32;

    %% Sweep ant_altitude
    sweep_altitude = linspace(5, 15, iter_qty);

    % Sweep grazing angle
    % NB1: This calculation fixes a negative discontinuity that was appearing
    %      in range resolution plots due to "HPBW overlap" at high grazing angles.
    % NB2: Adding eps to nudge the adjusted maximum just a bit above the overlap
    %       point, ensuting the minimum grazing angle w/r HPBW is < 90 degrees.
    grz_ang_max_wr_hpbw_elev = 90 - (model0.ant_hpbw_elevation_deg + eps);
    sweep_grz_ang = linspace(2, grz_ang_max_wr_hpbw_elev, iter_qty);

    results_range_res = zeros(iter_qty, iter_qty);
    results_azim_res = zeros(iter_qty, iter_qty);
    results_dopp_pcsn = zeros(iter_qty, iter_qty);
    results_pdet_multi = zeros(iter_qty, iter_qty);
    results_swath = zeros(iter_qty, iter_qty);
    results_twarn = zeros(iter_qty, iter_qty);
    results_t2cn_multi = zeros(iter_qty, iter_qty);

    saved_ant_altitude_km = model0.ant_altitude_km;
    saved_ant_bs_grazing_ang_mid_deg = model0.ant_bs_grazing_ang_mid_deg;

    for idx_altitude = 1:iter_qty
        for idx_grzang = 1:iter_qty
            fprintf('iteration: %d of %d\n', (idx_altitude - 1) * iter_qty + (idx_grzang), iter_qty ^ 2);

            model0.ant_altitude_km = sweep_altitude(idx_altitude);
            model0.ant_bs_grazing_ang_mid_deg = sweep_grz_ang(idx_grzang);

            results_range_res(idx_altitude, idx_grzang) = model0.worst_case_pulse_rng_res_m;
            results_azim_res(idx_altitude, idx_grzang) = model0.worst_case_pulse_azim_res_m;
            results_dopp_pcsn(idx_altitude, idx_grzang) = model0.worst_case_doppler_precision_hz;
            results_pdet_multi(idx_altitude, idx_grzang) = model0.worst_case_p_det_multi_pulse;
            results_swath(idx_altitude, idx_grzang) = model0.swath_width_km;
            results_twarn(idx_altitude, idx_grzang) = model0.t_warn_sec;
            results_t2cn_multi(idx_altitude, idx_grzang) = model0.worst_case_tgt_to_clutter_noise_noncoh_multi_db;

        end
    end

    % Restore original config
    model0.ant_altitude_km = saved_ant_altitude_km;
    model0.ant_bs_grazing_ang_mid_deg = saved_ant_bs_grazing_ang_mid_deg;

    %% Generte Plots
    % Plot 1: Pdet_1Look
    figure;
    tiledlayout(1, 2);

    nexttile;
    [X, Y] = meshgrid(sweep_altitude, sweep_grz_ang);
    % Intentionally transposed from data capture b/c meshgrid/matlab is like that (row/col index priority swap)
    surf(X, Y, results_pdet_multi.');
    hold on;
    Zslice = zeros(size(X, 1));
    Zslice(Zslice == 0) = 0.55;
    surf_req = surf(X, Y, Zslice, 'FaceColor', [0.4940 0.1840 0.5560], 'FaceAlpha', 0.5);
    title('Pdet Single Look vs. Alt/GrzAng')
    % AXES LABELS CHECKED OK
    xlabel('Platform Altitude (km)');
    ylabel('BS Grazing Angle (deg)');
    zlabel('Detection Probability - Single Look (pct)');
    legend(surf_req, 'Requirement Threshold');

    nexttile;
    filter_linidx = find(results_pdet_multi > 0.55);
    [xfilter, yfilter] = ind2sub([iter_qty iter_qty], filter_linidx);
    scatter(sweep_altitude(xfilter), sweep_grz_ang(yfilter), [], [0.4940 0.1840 0.5560]);
    title('Acceptable Alt/GrzAng for Pdet Single Look >= 0.55')
    % AXES LABELS CHECKED OK
    xlabel('Platform Altitude (km)');
    ylabel('BS Grazing Angle (deg)');
    legend('Meets Requirement');

    % Plot 2: Doppler Precision
    figure;
    tiledlayout(1, 2);

    nexttile;
    [X, Y] = meshgrid(sweep_altitude, sweep_grz_ang);
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
    title('Doppler Precision vs. Alt/GrzAng')
    % AXES LABELS CHECKED OK
    xlabel('Platform Altitude (km)');
    ylabel('BS Grazing Angle (deg)');
    zlabel('Doppler Precision (Hz, log scale)');
    legend([surf_req, surf_goal], 'Requirement Threshold', 'Goal Threshold');

    nexttile;
    filter_linidx_req = find(results_dopp_pcsn < 700 & results_dopp_pcsn > 50);
    [xfilter_req, yfilter_req] = ind2sub([iter_qty iter_qty], filter_linidx_req);
    scatter(sweep_altitude(xfilter_req), sweep_grz_ang(yfilter_req), [], [0.9290 0.6940 0.1250]);
    hold on;
    filter_linidx_goal = find(results_dopp_pcsn <= 50);
    [xfilter_goal, yfilter_goal] = ind2sub([iter_qty iter_qty], filter_linidx_goal);
    scatter(sweep_altitude(xfilter_goal), sweep_grz_ang(yfilter_goal), [], 'Green');
    title('Acceptable Alt/GrzAng for Doppler Precision < 700 Hz')
    % AXES LABELS CHECKED OK
    xlabel('Platform Altitude (km)');
    ylabel('BS Grazing Angle (deg)');
    legend('Meets Requirement', 'Meets Goal');

    % Plot 3: Range/Azim Resolution
    figure;
    tiledlayout(1, 2);

    nexttile;
    [X, Y] = meshgrid(sweep_altitude, sweep_grz_ang);
    % Intentionally transposed from data capture b/c meshgrid/matlab is like that (row/col index priority swap)
    surf(X, Y, results_azim_res.');
    hold on;
    Zslice_req = zeros(size(X, 1));
    Zslice_req(Zslice_req == 0) = 6;
    surf_req = surf(X, Y, Zslice_req, 'FaceColor', [0.9290 0.6940 0.1250], 'FaceAlpha', 0.5);
    title('Azimuth Resolution vs. Alt/GrzAng')
    % AXES LABELS CHECKED OK
    xlabel('Platform Altitude (km)');
    ylabel('BS Grazing Angle (deg)');
    zlabel('Azimuth Resolution (m)');
    legend(surf_req, 'Requirement Threshold');

    nexttile;
    [X, Y] = meshgrid(sweep_altitude, sweep_grz_ang);
    % Intentionally transposed from data capture b/c meshgrid/matlab is like that (row/col index priority swap)
    surf(X, Y, results_range_res.');
    hold on;
    Zslice_req = zeros(size(X, 1));
    Zslice_req(Zslice_req == 0) = 6;
    surf_req = surf(X, Y, Zslice_req, 'FaceColor', [0.9290 0.6940 0.1250], 'FaceAlpha', 0.5);
    title('Range Resolution vs. Alt/GrzAng')
    % AXES LABELS CHECKED OK
    xlabel('Platform Altitude (km)');
    ylabel('BS Grazing Angle (deg)');
    zlabel('Range Resolution (m)');
    legend(surf_req, 'Requirement Threshold');

    figure;

    res_mat_mins = zeros(iter_qty, iter_qty);
    for idx_x = 1:iter_qty
        for idx_y = 1:iter_qty
            res_mat_mins(idx_x, idx_y) = min([results_azim_res(idx_x, idx_y), results_range_res(idx_x, idx_y)]);
        end
    end

    filter_linidx_mins = find(res_mat_mins > 6);
    [xfilter_req, yfilter_req] = ind2sub([iter_qty iter_qty], filter_linidx_mins);
    scatter(sweep_altitude(xfilter_req), sweep_grz_ang(yfilter_req), [], [0.9290 0.6940 0.1250]);
    title('Acceptable Alt/GrzAng for Azim/Range Resolution')
    % AXES LABELS CHECKED OK
    xlabel('Platform Altitude (km)');
    ylabel('BS Grazing Angle (deg)');
    legend('Meets Alt. & Grz. Ang. Requirements');

    % Plot 4: Swath Width
    figure;
    tiledlayout(1, 2);

    nexttile;
    [X, Y] = meshgrid(sweep_altitude, sweep_grz_ang);
    % Intentionally transposed from data capture b/c meshgrid/matlab is like that (row/col index priority swap)
    surf(X, Y, results_swath.');
    hold on;
    Zslice_req = zeros(size(X, 1));
    Zslice_req(Zslice_req == 0) = 10;
    surf_req = surf(X, Y, Zslice_req, 'FaceColor', [0.9290 0.6940 0.1250], 'FaceAlpha', 0.5);
    Zslice_goal = zeros(size(X, 1));
    Zslice_goal(Zslice_goal == 0) = 100;
    surf_goal = surf(X, Y, Zslice_goal, 'FaceColor', 'Green', 'FaceAlpha', 0.5);
    title('Swath Width vs. Alt/GrzAng')
    % AXES LABELS CHECKED OK
    xlabel('Platform Altitude (km)');
    ylabel('BS Grazing Angle (deg)');
    zlabel('Swath Width (km)');
    legend([surf_req, surf_goal], 'Requirement Threshold', 'Goal Threshold');

    nexttile;
    filter_linidx_req = find(results_swath > 10 & results_swath < 100);
    [xfilter_req, yfilter_req] = ind2sub([iter_qty iter_qty], filter_linidx_req);
    scatter(sweep_altitude(xfilter_req), sweep_grz_ang(yfilter_req), [], [0.9290 0.6940 0.1250]);
    hold on;
    filter_linidx_goal = find(results_swath >= 100);
    [xfilter_goal, yfilter_goal] = ind2sub([iter_qty iter_qty], filter_linidx_goal);
    scatter(sweep_altitude(xfilter_goal), sweep_grz_ang(yfilter_goal), [], 'Green');
    title('Acceptable Alt/GrzAng for Swath Width')
    % AXES LABELS CHECKED OK
    xlabel('Platform Altitude (km)');
    ylabel('BS Grazing Angle (deg)');
    legend('Meets Requirement', 'Meets Goal');

    % Plot 5: Twarn
    figure;
    tiledlayout(1, 2);

    nexttile;
    [X, Y] = meshgrid(sweep_altitude, sweep_grz_ang);
    % Intentionally transposed from data capture b/c meshgrid/matlab is like that (row/col index priority swap)
    surf(X, Y, results_twarn.');
    hold on;
    Zslice_req = zeros(size(X, 1));
    Zslice_req(Zslice_req == 0) = 10;
    surf_req = surf(X, Y, Zslice_req, 'FaceColor', [0.9290 0.6940 0.1250], 'FaceAlpha', 0.5);
    Zslice_goal = zeros(size(X, 1));
    Zslice_goal(Zslice_goal == 0) = 300;
    surf_goal = surf(X, Y, Zslice_goal, 'FaceColor', 'Green', 'FaceAlpha', 0.5);
    title('Warning Time vs. Alt/GrzAng')
    % AXES LABELS CHECKED OK
    xlabel('Platform Altitude (km)');
    ylabel('BS Grazing Angle (deg)');
    zlabel('Twarn (sec)');
    legend([surf_req, surf_goal], 'Requirement Threshold', 'Goal Threshold');
    % zlim([1 125]);

    nexttile;
    filter_linidx_req = find(results_twarn > 10 & results_twarn < 300);
    [xfilter_req, yfilter_req] = ind2sub([iter_qty iter_qty], filter_linidx_req);
    scatter(sweep_altitude(xfilter_req), sweep_grz_ang(yfilter_req), [], [0.9290 0.6940 0.1250]);
    hold on;
    filter_linidx_goal = find(results_twarn >= 300);
    [xfilter_goal, yfilter_goal] = ind2sub([iter_qty iter_qty], filter_linidx_goal);
    scatter(sweep_altitude(xfilter_goal), sweep_grz_ang(yfilter_goal), [], 'Green');
    title('Acceptable Alt/GrzAng for Warning Time')
    % AXES LABELS CHECKED OK
    xlabel('Platform Altitude (km)');
    ylabel('BS Grazing Angle (deg)');
    legend('Meets Requirement', 'Meets Goal');

    % Plot 6: T/(C+N) per Look
    figure;
    tiledlayout(1, 2);

    nexttile;
    [X, Y] = meshgrid(sweep_altitude, sweep_grz_ang);
    % Intentionally transposed from data capture b/c meshgrid/matlab is like that (row/col index priority swap)
    surf(X, Y, results_t2cn_multi.');
    hold on;
    Zslice = zeros(size(X, 1));
    surf_req = surf(X, Y, Zslice, 'FaceColor', [0.4940 0.1840 0.5560], 'FaceAlpha', 0.5);
    title('T/(C+N) per Look vs. Alt/GrzAng')
    % AXES LABELS CHECKED OK
    xlabel('Platform Altitude (km)');
    ylabel('BS Grazing Angle (deg)');
    zlabel('T/(C+N) (dbW)');
    legend(surf_req, '0 dB Plane');

    nexttile;
    filter_linidx = find(results_t2cn_multi > 0);
    [xfilter, yfilter] = ind2sub([iter_qty iter_qty], filter_linidx);
    scatter(sweep_altitude(xfilter), sweep_grz_ang(yfilter), [], 'green');
    hold on;
    filter_linidx = find(results_t2cn_multi <= 0);
    [xfilter, yfilter] = ind2sub([iter_qty iter_qty], filter_linidx);
    scatter(sweep_altitude(xfilter), sweep_grz_ang(yfilter), [], 'red');
    title('Acceptable Alt/GrzAng for T/(C+N)')
    % AXES LABELS CHECKED OK
    xlabel('Platform Altitude (km)');
    ylabel('BS Grazing Angle (deg)');
    legend('Positive Ratio', 'Negative Ratio');

    debug_hold;

end

function debug_hold
    disp('debug_hold');
end
