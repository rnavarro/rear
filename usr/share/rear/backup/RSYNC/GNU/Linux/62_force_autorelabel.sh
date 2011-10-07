[ -f $TMP_DIR/force.autorelabel ] && {

	> "${TMP_DIR}/selinux.autorelabel"

	case $RSYNC_PROTO in

	(ssh)
		# for some reason rsync changes the mode of backup after each run to 666
		ssh $RSYNC_USER@$RSYNC_HOST "chmod $v 755 ${RSYNC_PATH}/${RSYNC_PREFIX}/backup" 2>&8
		$BACKUP_PROG -a "${TMP_DIR}/selinux.autorelabel" \
		 "$RSYNC_USER@$RSYNC_HOST:${RSYNC_PATH}/${RSYNC_PREFIX}/backup/.autorelabel" 2>&8
		_rc=$?
		if [ $_rc -ne 0 ]; then
			LogPrint "Failed to create .autorelabel on ${RSYNC_PATH}/${RSYNC_PREFIX}/backup [${rsync_err_msg[$_rc]}]"
			#StopIfError "Failed to create .autorelabel on ${RSYNC_PATH}/${RSYNC_PREFIX}/backup"
		fi
		;;

	(rsync)
		$BACKUP_PROG -a "${TMP_DIR}/selinux.autorelabel" \
		 "${RSYNC_PROTO}://${RSYNC_USER}@${RSYNC_HOST}:${RSYNC_PORT}/${RSYNC_PATH}/${RSYNC_PREFIX}/backup/.autorelabel"
		_rc=$?
		if [ $_rc -ne 0 ]; then
			LogPrint "Failed to create .autorelabel on ${RSYNC_PATH}/${RSYNC_PREFIX}/backup [${rsync_err_msg[$_rc]}]"
			#StopIfError "Failed to create .autorelabel on ${RSYNC_PATH}/${RSYNC_PREFIX}/backup"
		fi
		;;

	(*)
		# probably using the BACKUP=NETFS workflow instead
		if [ -d "${BUILD_DIR}/outputfs/${NETFS_PREFIX}" ]; then
			if [ ! -f "${BUILD_DIR}/outputfs/${NETFS_PREFIX}/selinux.autorelabel" ]; then
				> "${BUILD_DIR}/outputfs/${NETFS_PREFIX}/selinux.autorelabel"
				StopIfError "Failed to create selinux.autorelabel on ${BUILD_DIR}/outputfs/${NETFS_PREFIX}"
			fi
		fi
		;;

	esac
	Log "Trigger (forced) autorelabel (SELinux) file"
}
