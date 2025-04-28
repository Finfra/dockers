<?php
if (!function_exists('getenv_docker')) {
    function getenv_docker($env, $default) {
        if ($fileEnv = getenv($env . '_FILE')) {
            return rtrim(file_get_contents($fileEnv), "\r\n");
        } else if (($val = getenv($env)) !== false) {
            return $val;
        } else {
            return $default;
        }
    }
}

// ** 데이터베이스 설정 ** //
define('DB_NAME', 'wordpress');
define('DB_USER', 'wordpress');
define('DB_PASSWORD', 'wordpress_password');
define('DB_HOST', 'wpDb1');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', 'utf8mb4_unicode_ci');

// ** 테이블 접두사 ** //
$table_prefix = 'wp_';

// ** 디버그 모드 ** //
define('WP_DEBUG', false);

// ** 기본 테마 설정 ** //
define('WP_DEFAULT_THEME', 'twentytwentyfour');

// ** 자동 업데이트 설정 ** //
define('AUTOMATIC_UPDATER_DISABLED', false);
define('WP_AUTO_UPDATE_CORE', true);

// ** 파일 시스템 설정 ** //
define('FS_METHOD', 'direct');

// ** HTTPS 설정 ** //
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && strpos($_SERVER['HTTP_X_FORWARDED_PROTO'], 'https') !== false) {
    $_SERVER['HTTPS'] = 'on';
}

// ** 추가 설정 ** //
if ($configExtra = getenv_docker('WORDPRESS_CONFIG_EXTRA', '')) {
    eval($configExtra);
}

// ** 사이트 URL 설정 (설치 완료 후에는 DB에 저장됨) ** //
define('WP_SITEURL', 'http://localhost:8080');
define('WP_HOME', 'http://localhost:8080');

// ** WordPress 디렉토리 경로 ** //
if (!defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/');
}

// ** WordPress 설정 파일 로드 ** //
require_once ABSPATH . 'wp-settings.php';

/** SSL 설정 */
define('WP_FORCE_SSL_ADMIN', true);
define('FORCE_SSL_ADMIN', true);

/** 환경 타입 설정 - 개발 환경으로 변경 */
define('WP_ENVIRONMENT_TYPE', 'development');

/** 응용 프로그램 비밀번호 강제 활성화 */
define('WP_APPLICATION_PASSWORDS_ENABLED', true);

/** 디버그 스크립트 설정 */
define('SCRIPT_DEBUG', true);

// ** WordPress 설정 파일 로드 ** //
require_once ABSPATH . 'wp-settings.php';
?>
