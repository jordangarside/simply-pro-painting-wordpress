<?php
/**
 * Simply Pro Painting theme functions and definitions.
 *
 * @package simply-pro-painting
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Enqueue front-end styles and scripts.
 */
function spp_enqueue_assets() {
	wp_enqueue_style(
		'spp-custom',
		get_theme_file_uri( 'assets/css/custom.css' ),
		array(),
		filemtime( get_theme_file_path( 'assets/css/custom.css' ) )
	);

	wp_enqueue_script(
		'spp-navigation',
		get_theme_file_uri( 'assets/js/navigation.js' ),
		array(),
		filemtime( get_theme_file_path( 'assets/js/navigation.js' ) ),
		array(
			'in_footer' => true,
			'strategy'  => 'defer',
		)
	);

	wp_enqueue_script(
		'spp-animations',
		get_theme_file_uri( 'assets/js/animations.js' ),
		array(),
		filemtime( get_theme_file_path( 'assets/js/animations.js' ) ),
		array(
			'in_footer' => true,
			'strategy'  => 'defer',
		)
	);
}
add_action( 'wp_enqueue_scripts', 'spp_enqueue_assets' );

/**
 * Set up theme support and editor styles.
 */
function spp_setup() {
	add_theme_support( 'title-tag' );
	add_editor_style( 'assets/css/editor.css' );
	add_editor_style( 'assets/css/custom.css' );
}
add_action( 'after_setup_theme', 'spp_setup' );

/**
 * Register custom block pattern category.
 */
function spp_register_pattern_categories() {
	register_block_pattern_category(
		'simply-pro-painting',
		array(
			'label' => __( 'Simply Pro Painting', 'simply-pro-painting' ),
		)
	);
}
add_action( 'init', 'spp_register_pattern_categories' );

/**
 * PaintScout lead form shortcode.
 *
 * Usage: [paintscout_form]
 *
 * @return string HTML markup for the PaintScout widget.
 */
function spp_paintscout_form() {
	return '<div id="widget-container"></div>
	<script src="https://forms.paintscout.com/lead-form-widget.js"
		data-company-id="infazywchkmwmuuq"
		data-lead-form-key="5ee99a2e-9204-441b-ace1-7bef76ff7a0c"></script>';
}
add_shortcode( 'paintscout_form', 'spp_paintscout_form' );

/**
 * Restrict available block types for editors on pages.
 *
 * Administrators retain access to every block. Editors are limited to a
 * curated set when editing pages so the layout stays consistent.
 *
 * @param bool|string[]          $allowed_block_types Array of allowed block type slugs, or true for all.
 * @param WP_Block_Editor_Context $editor_context      The current block editor context.
 * @return bool|string[] Filtered list of allowed block types.
 */
function spp_allowed_block_types( $allowed_block_types, $editor_context ) {
	if ( empty( $editor_context->post ) ) {
		return true;
	}

	$user = wp_get_current_user();

	if ( ! in_array( 'editor', (array) $user->roles, true ) ) {
		return true;
	}

	if ( 'page' !== $editor_context->post->post_type ) {
		return true;
	}

	// Home page (static front page): editors can only edit existing content.
	$front_page_id = (int) get_option( 'page_on_front' );
	if ( $front_page_id && $editor_context->post->ID === $front_page_id ) {
		return array(
			'core/heading',
			'core/paragraph',
			'core/image',
		);
	}

	return array(
		'core/paragraph',
		'core/heading',
		'core/image',
		'core/gallery',
		'core/list',
		'core/list-item',
		'core/buttons',
		'core/button',
		'core/group',
		'core/columns',
		'core/column',
		'core/cover',
		'core/spacer',
		'core/separator',
		'core/shortcode',
		'core/html',
	);
}
add_filter( 'allowed_block_types_all', 'spp_allowed_block_types', 10, 2 );

/**
 * Prevent editors from unlocking blocks.
 *
 * Editors cannot modify block locking — only administrators can.
 *
 * @param array $settings Block editor settings.
 * @return array Filtered settings.
 */
function spp_restrict_block_locking( $settings ) {
	$user = wp_get_current_user();
	if ( in_array( 'editor', (array) $user->roles, true ) ) {
		$settings['canLockBlocks'] = false;
	}
	return $settings;
}
add_filter( 'block_editor_settings_all', 'spp_restrict_block_locking' );

/**
 * Register custom dashboard widgets.
 */
function spp_dashboard_widgets() {
	wp_add_dashboard_widget(
		'spp_image_guidelines',
		__( 'Image Guidelines', 'simply-pro-painting' ),
		'spp_dashboard_image_guidelines'
	);

	wp_add_dashboard_widget(
		'spp_site_guide',
		__( 'Site Guide — How to Edit Your Website', 'simply-pro-painting' ),
		'spp_dashboard_site_guide'
	);
}
add_action( 'wp_dashboard_setup', 'spp_dashboard_widgets' );

/**
 * Render the Image Guidelines dashboard widget.
 */
function spp_dashboard_image_guidelines() {
	?>
	<style>
		#spp_image_guidelines ul {
			margin: 12px 0;
			padding: 0;
			list-style: none;
		}
		#spp_image_guidelines li {
			padding: 8px 0;
			border-bottom: 1px solid #f0f0f0;
			font-size: 13px;
			line-height: 1.6;
		}
		#spp_image_guidelines li:last-child {
			border-bottom: none;
		}
		#spp_image_guidelines strong {
			display: inline-block;
			min-width: 130px;
		}
		#spp_image_guidelines .spp-note {
			margin-top: 10px;
			padding: 8px 12px;
			background: #f7f7f7;
			border-left: 3px solid #2271b1;
			font-size: 12px;
			color: #555;
		}
	</style>
	<ul>
		<li>&#x1f5bc;&#xfe0f; <strong>Hero image:</strong> 1920 &times; 800px (landscape)</li>
		<li>&#x1f4f7; <strong>Gallery images:</strong> 800 &times; 600px minimum (4:3 preferred)</li>
		<li>&#x1f9d1; <strong>About image:</strong> 800 &times; 1000px (portrait or square)</li>
		<li>&#x2b50; <strong>Logo:</strong> 300px wide, transparent PNG</li>
	</ul>
	<div class="spp-note">
		CSS handles cropping via <code>object-fit</code> &mdash; these are recommendations for best results.
	</div>
	<?php
}

/**
 * Render the Site Guide dashboard widget.
 */
function spp_dashboard_site_guide() {
	?>
	<style>
		#spp_site_guide ul {
			margin: 12px 0;
			padding: 0;
			list-style: none;
		}
		#spp_site_guide li {
			padding: 10px 0;
			border-bottom: 1px solid #f0f0f0;
			font-size: 13px;
			line-height: 1.6;
		}
		#spp_site_guide li:last-child {
			border-bottom: none;
		}
		#spp_site_guide li strong {
			display: block;
			margin-bottom: 4px;
		}
	</style>
	<ul>
		<li>
			&#x1f3a8; <strong>Replace hero image</strong>
			Go to <em>Pages &rarr; Home</em> &rarr; click the hero image &rarr; <em>Replace</em> &rarr; Upload or select from Media Library.
		</li>
		<li>
			&#x1f5bc;&#xfe0f; <strong>Add gallery photos</strong>
			Go to <em>Pages &rarr; Gallery</em> &rarr; click the gallery &rarr; <em>Add images</em>.
		</li>
		<li>
			&#x1f504; <strong>Swap homepage gallery photos</strong>
			Go to <em>Pages &rarr; Home</em> &rarr; scroll to the gallery section &rarr; click any image &rarr; <em>Replace</em>.
		</li>
		<li>
			&#x270f;&#xfe0f; <strong>Edit text</strong>
			Click any text on a page and start typing.
		</li>
		<li>
			&#x1f4ac; <strong>Set alt text on images</strong>
			Click an image &rarr; look in the right sidebar &rarr; fill in the <em>"Alt text"</em> field.
		</li>
		<li>
			&#x1f4d0; <strong>Image sizes</strong>
			Refer to the <em>Image Guidelines</em> widget on this dashboard for recommended dimensions.
		</li>
	</ul>
	<?php
}
